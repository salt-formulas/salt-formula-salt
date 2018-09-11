# -*- coding: utf-8 -*-

import errno
import json
import logging
import os
import shutil
import six
import subprocess
import tempfile
import uuid
import yaml

LOG = logging.getLogger(__name__)

class ConfigDriveBuilder(object):
    """Build config drives, optionally as a context manager."""

    def __init__(self, image_file):
        self.image_file = image_file
        self.mdfiles=[]

    def __enter__(self):
        self._delete_if_exists(self.image_file)
        return self

    def __exit__(self, exctype, excval, exctb):
        self.make_drive()

    @staticmethod
    def _ensure_tree(path):
        try:
            os.makedirs(path)
        except OSError as e:
            if e.errno == errno.EEXIST and os.path.isdir(path):
                pass
            else:
                raise

    @staticmethod
    def _delete_if_exists(path):
        try:
            os.unlink(path)
        except OSError as e:
            if e.errno != errno.ENOENT:
                raise

    def add_file(self, path, data):
        self.mdfiles.append((path, data))

    def _add_file(self, basedir, path, data):
        filepath = os.path.join(basedir, path)
        dirname = os.path.dirname(filepath)
        self._ensure_tree(dirname)
        with open(filepath, 'wb') as f:
            if isinstance(data, six.text_type):
                data = data.encode('utf-8')
            f.write(data)

    def _write_md_files(self, basedir):
        for data in self.mdfiles:
            self._add_file(basedir, data[0], data[1])

    def _make_iso9660(self, path, tmpdir):
        cmd = ['mkisofs',
            '-o', path,
            '-ldots',
            '-allow-lowercase',
            '-allow-multidot',
            '-l',
            '-V', 'config-2',
            '-r',
            '-J',
            '-quiet',
            tmpdir]
        try:
            LOG.info('Running cmd (subprocess): %s', cmd)
            _pipe = subprocess.PIPE
            obj = subprocess.Popen(cmd,
                       stdin=_pipe,
                       stdout=_pipe,
                       stderr=_pipe,
                       close_fds=True)
            (stdout, stderr) = obj.communicate()
            obj.stdin.close()
            _returncode = obj.returncode
            LOG.debug('Cmd "%s" returned: %s', cmd, _returncode)
            if _returncode != 0:
                output = 'Stdout: %s\nStderr: %s' % (stdout, stderr)
                LOG.error('The command "%s" failed. %s',
                          cmd, output)
                raise subprocess.CalledProcessError(cmd=cmd,
                                                    returncode=_returncode,
                                                    output=output)
        except OSError as err:
            LOG.error('Got an OSError in the command: "%s". Errno: %s', cmd,
                      err.errno)
            raise

    def make_drive(self):
        """Make the config drive.
        :raises CalledProcessError if a helper process has failed.
        """
        try:
            tmpdir = tempfile.mkdtemp()
            self._write_md_files(tmpdir)
            self._make_iso9660(self.image_file, tmpdir)
        finally:
            shutil.rmtree(tmpdir)


def generate(dst, hostname, domainname, instance_id=None, user_data=None,
             network_data=None):

    ''' Generate config drive

    :param dst: destination file to place config drive.
    :param hostname: hostname of Instance.
    :param domainname: instance domain.
    :param instance_id: UUID of the instance.
    :param user_data: custom user data dictionary.
    :param network_data: custom network info dictionary.

    '''
    instance_md = {}
    instance_md['uuid'] = instance_id or str(uuid.uuid4())
    instance_md['hostname'] = '%s.%s' % (hostname, domainname)
    instance_md['name'] = hostname

    if user_data:
        user_data = '#cloud-config\n\n' + yaml.dump(user_data, default_flow_style=False)

    data = json.dumps(instance_md)
    with ConfigDriveBuilder(dst) as cfgdrive:
        cfgdrive.add_file('openstack/latest/meta_data.json', data)
        if user_data:
            cfgdrive.add_file('openstack/latest/user_data', user_data)
        if network_data:
            cfgdrive.add_file('openstack/latest/network_data.json', json.dumps(network_data))

    LOG.debug('Config drive was built %s' % dst)
