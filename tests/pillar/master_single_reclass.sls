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
      address:  'git@git.domain.com'
      branch: master
salt:
  master:
    enabled: true
    command_timeout: 5
    worker_threads: 2
    base_environment: prd
    environment:
      prd:
        formula:
          service01:
            source: git
            address: 'git@git.domain.com/service01-formula.git'
            revision: master
          service02:
            source: pkg
            name: salt-formula-service02
    pillar:
      engine: reclass
      data_dir: /srv/salt/reclass
