
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

.. code-block:: yaml

    salt:
      master:
        ...
      api:
        enabled: true
        port: 8000

Salt master with preset minions

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        minions:
        - name: 'node1.system.location.domain.com'

Salt master syndicate master of masters

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        syndic:
          mode: master

Salt master syndicate (client) master

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        syndicate:
          mode: client
          host: master-master

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

Salt virt KVM cluster

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

salt-virt
---------

Sample pillar

.. code-block:: yaml

  salt:
    control:
      enabled: True
      virt_enabled: True
      size:
        medium:
          cpu: 2
          ram: 1024
      cluster:
        localnode:
          domain: domain.com
          engine: virt
          config:
            engine: salt
            host: 127.0.0.1
          node:
            ubuntu01:
              provider: node001.domain.com
              image: ubuntu-14-04-x64-1456128611.qcow2
              size: medium
              disk_profile: database
              net_profile: testing