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
