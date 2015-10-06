
====  
Salt
====

Salt is a new approach to infrastructure management. Easy enough to get running in minutes, scalable enough to manage tens of thousands of servers, and fast enough to communicate with them in seconds.

Salt delivers a dynamic communication bus for infrastructures that can be used for orchestration, remote execution, configuration management and much more.

Sample pillars
==============

Salt master
-----------

Salt master with base environment and pillar metadata source

.. code-block:: yaml

    salt:
      master:
        enabled: true
        command_timeout: 5
        worker_threads: 2
        pillar:
          engine: salt
          source:
            engine: git
            address: 'git@repo.domain.com:salt/pillar-demo.git'
            branch: 'master'
        base_environment: prd
        environment:
          prd:
            enabled: true
            formula:
              linux:
                source: git
                address: 'git@repo.domain.com:salt/formula-linux.git'
                branch: 'master'
              salt:
                source: git
                address: 'git@repo.domain.com:salt/formula-salt.git'
                branch: 'master'
              openssh:
                source: git
                address: 'git@repo.domain.com:salt/formula-openssh.git'
                branch: 'master'

Simple Salt master with base environment and custom states

.. code-block:: yaml

    salt:
      master:
        ...
        environment:
          base:
            states:
            - name: gitlab
              source: git
              address: 'git@repo.domain.cz:salt/state-gitlab.git'
              branch: 'master'
            formulas:
            ...

Salt master with reclass ENC

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        pillar:
          engine: reclass
          data_dir: /srv/salt/reclass

Salt master with windows repository

.. code-block:: yaml

    salt:
      master:
        enabled: true
        ...
        windows_repo:
          type: git
          address: 'git@repo.domain.com:salt/win-packages.git'

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
        command_timeout: 5
        worker_threads: 2
        environments:
        - name: base
          states:
          - source: git
            address: 'git@repo.domain.com:salt/state-ubuntu.git'
            branch: 'master'
          pillar:
            source: git
            address: 'git@repo.domain.com:salt/pillar-demo.git'
            branch: 'master'
        handlers:
          name: logstash
          type: udp
          bind:
            host: 127.0.0.1
            port: 9999
      minion:
        handlers:
        - engine: udp
          bind:
            host: 127.0.0.1
            port: 9999
        - engine: zmq
          bind:
            host: 127.0.0.1
            port: 9999

Salt minion
-----------

Simplest Salt minion

.. code-block:: yaml

    salt:
      minion:
        enabled: true
        master:
          host: master.domain.com

Multi-master Salt minion

.. code-block:: yaml

    salt:
      minion:
        enabled: true
        masters:
        -  host: master1.domain.com
        -  host: master2.domain.com

Salt minion with salt mine options

    salt:
      minion:
        enabled: true
        master:
          host: master.domain.com
        mine:
          interval: 60
          module:
            grains.items: []
            network.interfaces: []

Salt minion with graphing dependencies

.. code-block:: yaml

    salt:
      minion:
        enabled: true
        graph_states: true
        master:
          host: master.domain.com

Salt control (cloud/virt)
-------------------------

Salt cloud with local OpenStack insecure (ignoring SSL cert errors) provider 

.. code-block:: yaml

    salt:
      control:
        enabled: true
        provider:
          openstack_account:
            engine: openstack
            insecure: true
            region: RegionOne
            identity_url: 'https://10.0.0.2:35357'
            tenant: devops
            user: user
            password: 'password'
            fixed_networks:
            - 123d3332-18be-4d1d-8d4d-5f5a54456554e
            floating_networks:
            - public
            ignore_cidr: 192.168.0.0/16

Salt cloud with Digital Ocean provider

.. code-block:: yaml

    salt:
      control:
        enabled: true
        provider:
          dony1:
            engine: digital_ocean
            region: New York 1
            client_key: xxxxxxx
            api_key: xxxxxxx

Salt cloud with cluster definition

.. code-block:: yaml

    salt:
      control:
        enabled: true
        cluster:
          devops_ase:
            config:
              engine: salt
              host: 147.32.120.1
            node:
              proxy1.ase.cepsos.cz:
                provider: cepsos_devops
                image: Ubuntu12.04 x86_64
                size: m1.medium
              node1.ase.cepsos.cz:
                provider: cepsos_devops
                image: Ubuntu12.04 x86_64
                size: m1.medium
              node2.ase.cepsos.cz:
                provider: cepsos_devops
                image: Ubuntu12.04 x86_64
                size: m1.medium
              node3.ase.cepsos.cz:
                provider: cepsos_devops
                image: Ubuntu12.04 x86_64
                size: m1.medium

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
