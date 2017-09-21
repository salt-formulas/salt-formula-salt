from __future__ import absolute_import

# Import python libs
import logging
import os

try:
    import paramiko
    HAS_PARAMIKO = True
except:
    HAS_PARAMIKO = False

# Import Salt libs
import salt.config
import salt.wheel

LOG = logging.getLogger(__name__)


def __virtual__():
    '''
    Only load if paramiko library exist.
    '''
    if not HAS_PARAMIKO:
        return (
            False,
            'Can not load module saltkey: paramiko library not found')
    return True


def key_create(id_, host, force=False):
    '''
    Generates minion keypair, accepts it on master and injects it to minion via SSH.

    :param id_: expected minion ID of target node
    :param host: IP address or resolvable hostname/FQDN of target node

    CLI Examples:

    .. code-block:: bash

        salt-call saltkey.key_create <MINION_ID> <MINION_IP_ADDRESS> force=False
    '''
    ret = {
        'retcode': 0,
        'msg': 'Salt Key for minion %s is already accepted' % id_,
    }

    opts = salt.config.master_config('/etc/salt/master')
    wheel = salt.wheel.WheelClient(opts)
    keys = wheel.cmd('key.gen_accept', arg=[id_], kwarg={'force': force})
    pub_key = keys.get('pub', None)
    priv_key = keys.get('priv', None)

    if pub_key and priv_key:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        # Establish SSH connection to minion
        try:
            ssh.connect(host)
        except paramiko.ssh_exception.AuthenticationException:
            msg = ('Could not establish SSH connection to minion "%s" on address %s, please ensure '
                   'that current user\'s SSH key is present in minions authorized_keys.') % (id_, host)
            LOG.error(msg)
            ret['retcode'] = 1
            ret['msg'] = msg
            wheel.cmd_async({'fun': 'key.delete', 'match': id_})
            return ret
        except Exception as e:
            msg = ('Unknown error occured while establishing SSH connection '
                   'to minion "%s" on address %s: %s') % (id_, host, repr(e))
            LOG.error(msg)
            ret['retcode'] = 1
            ret['msg'] = msg
            wheel.cmd_async({'fun': 'key.delete', 'match': id_})
            return ret
        # Setup the keys on minion side the ugly way, nice one didn't work
        key_path = '/etc/salt/pki/minion'
        command = ('echo "%(pub_key)s" > %(pub_path)s && chmod 644 %(pub_path)s && '
                   'echo "%(priv_key)s" > %(priv_path)s && chmod 400 %(priv_path)s && '
                   'salt-call --local service.restart salt-minion') % {
            'pub_path': os.path.join(key_path, 'minion.pub'),
            'pub_key': pub_key,
            'priv_path': os.path.join(key_path, 'minion.pem'),
            'priv_key': priv_key
        }

        ssh_chan = ssh.get_transport().open_session()
        ssh_chan.exec_command(command)
        # Wait for command return
        while True:
            if ssh_chan.exit_status_ready():
                exit_status = ssh_chan.recv_exit_status()
                stderr = ssh_chan.recv_stderr(1000)
                stdout = ssh_chan.recv(1000)
                break
        ssh.close()
        # Evaluate SSH command exit status
        if exit_status != 0:
            msg = 'Keypair injection to Salt minion failed on target with following error: %s' % stderr
            LOG.error(msg)
            ret['retcode'] = exit_status
            ret['msg'] = msg
            return ret

        ret['msg'] = 'Salt Key successfully created'

    return ret

