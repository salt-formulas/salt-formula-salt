
============
Salt Formula
============

Salt is a new approach to infrastructure management. Easy enough to get
running in minutes, scalable enough to manage tens of thousands of servers,
and fast enough to communicate with them in seconds.

Salt delivers a dynamic communication bus for infrastructures that can be used
for orchestration, remote execution, configuration management and much more.


Sample Metadata
===============


Salt master
-----------

Salt master with base formulas and pillar metadata backend

.. literalinclude:: tests/pillar/master_single_pillar.sls
   :language: yaml

Salt master with reclass ENC metadata backend

.. literalinclude:: tests/pillar/master_single_reclass.sls
   :language: yaml

Salt master with API

.. literalinclude:: tests/pillar/master_api.sls
   :language: yaml

Salt master with defined user ACLs

.. literalinclude:: tests/pillar/master_acl.sls
   :language: yaml

Salt master with preset minions

.. code-block:: yaml

    salt:
      master:
        enabled: true
        minions:
        - name: 'node1.system.location.domain.com'

Salt master with pip based installation (optional)

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        source:
          engine: pip
          version: 2016.3.0rc2

Install formula through system package management

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        environment:
          prd:
            keystone:
              source: pkg
              name: salt-formula-keystone
            nova:
              source: pkg
              name: salt-formula-keystone
              version: 0.1+0~20160818133412.24~1.gbp6e1ebb
            postresql:
              source: pkg
              name: salt-formula-postgresql
              version: purged

Formula keystone is installed latest version and the formulas without version are installed in one call to aptpkg module.
If the version attribute is present sls iterates over formulas and take action to install specific version or remove it.
The version attribute may have these values ``[latest|purged|removed|<VERSION>]``.

Clone master branch of keystone formula as local feature branch

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        environment:
          dev:
            formula:
              keystone:
                source: git
                address: git@github.com:openstack/salt-formula-keystone.git
                revision: master
                branch: feature

Salt master with specified formula refs (for example for Gerrit review)

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        environment:
          dev:
            formula:
              keystone:
                source: git
                address: https://git.openstack.org/openstack/salt-formula-keystone
                revision: refs/changes/56/123456/1

Salt master with logging handlers

.. code-block:: yaml

    salt:
      master:
        enabled: true
        handler:
          handler01:
            engine: udp
            bind:
              host: 127.0.0.1
              port: 9999
      minion:
        handler:
          handler01:
            engine: udp
            bind:
              host: 127.0.0.1
              port: 9999
          handler02:
            engine: zmq
            bind:
              host: 127.0.0.1
              port: 9999


Salt engine definition for saltgraph metadata collector

.. code-block:: yaml

    salt:
      master:
        engine:
          graph_metadata:
            engine: saltgraph
            host: 127.0.0.1
            port: 5432
            user: salt
            password: salt
            database: salt

Salt engine definition for sending events from docker events

.. code-block:: yaml

    salt:
      master:
        engine:
          docker_events:
            docker_url: unix://var/run/docker.sock

Salt master peer setup for remote certificate signing

.. code-block:: yaml

    salt:
      master:
        peer:
          ".*":
          - x509.sign_remote_certificate

Configure verbosity of state output (used for `salt` command)

.. code-block:: yaml

    salt:
      master:
        state_output: changes

Salt synchronise node pillar and modules after start

.. code-block:: yaml

    salt:
      master:
        reactor:
          salt/minion/*/start:
          - salt://salt/reactor/node_start.sls

Trigger basic node install

.. code-block:: yaml

    salt:
      master:
        reactor:
          salt/minion/install:
          - salt://salt/reactor/node_install.sls

Sample event to trigger the node installation

.. code-block:: bash

    salt-call event.send 'salt/minion/install'

Run any defined orchestration pipeline

.. code-block:: yaml

    salt:
      master:
        reactor:
          salt/orchestrate/start:
          - salt://salt/reactor/orchestrate_start.sls

Event to trigger the orchestration pipeline

.. code-block:: bash

    salt-call event.send 'salt/orchestrate/start' "{'orchestrate': 'salt/orchestrate/infra_install.sls'}"

Synchronise modules and pillars on minion start.

.. code-block:: yaml

    salt:
      master:
        reactor:
          'salt/minion/*/start':
          - salt://salt/reactor/minion_start.sls

Add and/or remove the minion key

.. code-block:: yaml

    salt:
      master:
        reactor:
          salt/key/create:
          - salt://salt/reactor/key_create.sls
          salt/key/remove:
          - salt://salt/reactor/key_remove.sls

Event to trigger the key creation

.. code-block:: bash

    salt-call event.send 'salt/key/create' \
    > "{'node_id': 'id-of-minion', 'node_host': '172.16.10.100', 'orch_post_create': 'kubernetes.orchestrate.compute_install', 'post_create_pillar': {'node_name': 'id-of-minion'}}"

.. note::

    You can add pass additional `orch_pre_create`, `orch_post_create`,
    `orch_pre_remove` or `orch_post_remove` parameters to the event to call
    extra orchestrate files. This can be useful for example for
    registering/unregistering nodes from the monitoring alarms or dashboards.

    The key creation event needs to be run from other machine than the one
    being registered.

Event to trigger the key removal

.. code-block:: bash

    salt-call event.send 'salt/key/remove'

Salt syndic
-----------

The master of masters

.. code-block:: yaml

    salt:
      master:
        enabled: true
        order_masters: True

Lower syndicated master

.. code-block:: yaml

    salt:
      syndic:
        enabled: true
        master:
          host: master-of-master-host
        timeout: 5

Syndicated master with multiple master of masters

.. code-block:: yaml

    salt:
      syndic:
        enabled: true
        masters:
        - host: master-of-master-host1
        - host: master-of-master-host2
        timeout: 5


Salt-minion proxy
-----------------

Salt proxy pillar

.. code-block:: yaml

    salt:
      minion:
        proxy_minion:
          master: localhost
          device:
            vsrx01.mydomain.local:
              enabled: true
              engine: napalm
            csr1000v.mydomain.local:
              enabled: true
              engine: napalm

.. note:: This is pillar of the the real salt-minion


Proxy pillar for IOS device

.. code-block:: yaml

    proxy:
      proxytype: napalm
      driver: ios
      host: csr1000v.mydomain.local
      username: root
      passwd: r00tme

.. note:: This is pillar of the node thats not able to run salt-minion itself


Proxy pillar for JunOS device

.. code-block:: yaml

    proxy:
      proxytype: napalm
      driver: junos
      host: vsrx01.mydomain.local
      username: root
      passwd: r00tme
      optional_args:
        config_format: set

.. note:: This is pillar of the node thats not able to run salt-minion itself


Salt SSH
--------

Salt SSH with sudoer using key

.. literalinclude:: tests/pillar/master_ssh_minion_key.sls
   :language: yaml

Salt SSH with sudoer using password

.. literalinclude:: tests/pillar/master_ssh_minion_password.sls
   :language: yaml

Salt SSH with root using password

.. literalinclude:: tests/pillar/master_ssh_minion_root.sls
   :language: yaml


Salt minion
-----------

Simplest Salt minion setup with central configuration node

.. code-block:: yaml

.. literalinclude:: tests/pillar/minion_master.sls
   :language: yaml

Multi-master Salt minion setup

.. literalinclude:: tests/pillar/minion_multi_master.sls
   :language: yaml

Salt minion with salt mine options

.. literalinclude:: tests/pillar/minion_mine.sls
   :language: yaml

Salt minion with graphing dependencies

.. literalinclude:: tests/pillar/minion_graph.sls
   :language: yaml

Salt minion behind HTTP proxy

.. code-block:: yaml

    salt:
      minion:
        proxy:
          host: 127.0.0.1
          port: 3128

Salt minion to specify non-default HTTP backend. The default tornado backend
does not respect HTTP proxy settings set as environment variables. This is
useful for cases where you need to set no_proxy lists.

.. code-block:: yaml

    salt:
      minion:
        backend: urllib2


Salt minion with PKI certificate authority (CA)

.. literalinclude:: tests/pillar/minion_pki_ca.sls
   :language: yaml

Salt minion using PKI certificate

.. literalinclude:: tests/pillar/minion_pki_cert.sls
   :language: yaml

Salt minion trust CA certificates issued by salt CA on a specific host (ie: salt-master node)

.. code-block:: yaml

  salt:
    minion:
      trusted_ca_minions:
        - cfg01

Salt control (cloud/kvm/docker)
-------------------------------

Salt cloud with local OpenStack provider

.. literalinclude:: tests/pillar/control_cloud_openstack.sls
   :language: yaml

Salt cloud with Digital Ocean provider

.. literalinclude:: tests/pillar/control_cloud_digitalocean.sls
   :language: yaml

Salt virt with KVM cluster

.. literalinclude:: tests/pillar/control_virt.sls
   :language: yaml


Usage
=====

Working with salt-cloud

.. code-block:: bash

    salt-cloud -m /path/to/map --assume-yes

Debug LIBCLOUD for salt-cloud connection

.. code-block:: bash

    export LIBCLOUD_DEBUG=/dev/stderr; salt-cloud --list-sizes provider_name --log-level all


More Information
================

* http://salt.readthedocs.org/en/latest/
* https://github.com/DanielBryan/salt-state-graph
* http://karlgrz.com/testing-salt-states-rapidly-with-docker/
* https://mywushublog.com/2013/03/configuration-management-with-salt-stack/
* http://russell.ballestrini.net/replace-the-nagios-scheduler-and-nrpe-with-salt-stack/
* https://github.com/saltstack-formulas/salt-formula
* http://docs.saltstack.com/en/latest/topics/tutorials/multimaster.html


salt-cloud
----------

* http://www.blog.sandro-mathys.ch/2013/07/setting-user-password-when-launching.html
* http://cloudinit.readthedocs.org/en/latest/topics/examples.html
* http://salt-cloud.readthedocs.org/en/latest/topics/install/index.html
* http://docs.saltstack.com/topics/cloud/digitalocean.html
* http://salt-cloud.readthedocs.org/en/latest/topics/rackspace.html
* http://salt-cloud.readthedocs.org/en/latest/topics/map.html
* http://docs.saltstack.com/en/latest/topics/tutorials/multimaster.html


Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-salt/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-salt

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net
