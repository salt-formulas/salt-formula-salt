git:
  client:
    enabled: true
linux:
  system:
    enabled: true
reclass:
  storage:
    enabled: true
    data_source:
      engine: git
      branch: master
      address: 'https://github.com/salt-formulas/openstack-salt.git'
salt:
  master:
    enabled: true
    command_timeout: 5
    worker_threads: 2
    base_environment: prd
    #environment:
    # prd:
    #   formula:
    #     python:
    #       source: git
    #       address: 'https://github.com/salt-formulas/salt-formula-python.git'
    #       revision: master
    pillar:
      engine: composite
      reclass:
        # index: 1 is default value
        index: 1
        storage_type: yaml_fs
        inventory_base_uri: /srv/salt/reclass_encrypted
        class_mappings:
          - target: '/^cfg\d+/'
            class:  system.non-existing.class
        ignore_class_notfound: True
        ignore_class_regexp:
          - 'service.*'
          - '*.fluentd'
        propagate_pillar_data_to_reclass: False
      stack: # not yet implemented
        # https://docs.saltstack.com/en/latest/ref/pillar/all/salt.pillar.stack.html
        #option 1
        #path:
        #  - /path/to/stack.cfg
        #option 2
        pillar:environment:
          dev: path/to/dev/stasck.cfg
          prod: path/to/prod/stasck.cfg
        grains:custom:grain:
          value:
            - /path/to/stack1.cfg
            - /path/to/stack2.cfg
      saltclass:
        path: /srv/salt/saltclass
      nacl:
        # if order is provided 99 is used to compose "99-nacl" key name which is later used to order entries
        index: 99
      gpg: {}
      vault-1: # not yet implemented
        name: vault
        path: secret/salt
      vault-2: # not yet implemented
        name: vault
        path: secret/root
    vault: # not yet implemented
      # https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.vault.html
      name: myvault
      url: https://vault.service.domain:8200
      auth:
          method: token
          token: 11111111-2222-3333-4444-555555555555
      policies:
          - saltstack/minions
          - saltstack/minion/{minion}
    nacl:
      # https://docs.saltstack.com/en/develop/ref/modules/all/salt.modules.nacl.html
      box_type: sealedbox
      sk_file: /etc/salt/pki/master/nacl
      pk_file: /etc/salt/pki/master/nacl.pub
      #sk: None
      #pk: None
