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
      engine: reclass
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
