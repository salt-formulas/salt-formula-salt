
====
Salt
====

Salt is a new approach to infrastructure management. Easy enough to get running in minutes, scalable enough to manage tens of thousands of servers, and fast enough to communicate with them in seconds.

Salt delivers a dynamic communication bus for infrastructures that can be used for orchestration, remote execution, configuration management and much more.

Sample pillars
==============

Salt master
-----------

Salt master with base production environment and pillar tree as metadata backend

.. literalinclude:: tests/pillar/master_single_pillar.sls
   :language: yaml

Salt master with reclass ENC as metadata backend

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

Salt master with alternative installation source and version (optional) - pip

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        source:
          engine: pip
          version: 2016.3.0rc2

Salt master with specified formula to install through apt-get

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        environment:
          prd:
            keysone:
              source: pkg
              name: salt-formula-keystone

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

Salt syndic: Master of masters

.. code-block:: yaml

    salt:
      master:
        enabled: true
        order_masters: True

Salt syndic: Lower master

.. code-block:: yaml

    salt:
      syndic:
        enabled: true
        master:
          host: master-of-master-host
        timeout: 5

Salt syndic: Lower master with multi-master of masters

.. code-block:: yaml

    salt:
      syndic:
        enabled: true
        masters:
        - host: master-of-master-host1
        - host: master-of-master-host2
        timeout: 5


Salt master with custom handlers

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

Salt master peer for remote certificate sign.

.. code-block:: yaml

    salt:
      master:
        peer:
          ".*":
          - x509.sign_remote_certificate


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

Salt minion behind http proxy

.. code-block:: yaml

    salt:
      minion:
        proxy:
          host: 127.0.0.1
          port: 3128

PKI CA
~~~~~~

Salt minion with PKI CA

.. literalinclude:: tests/pillar/minion_pki_ca.sls
   :language: yaml

Salt minion with PKI certificate

.. literalinclude:: tests/pillar/minion_pki_cert.sls
   :language: yaml


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


Read more
=========

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
