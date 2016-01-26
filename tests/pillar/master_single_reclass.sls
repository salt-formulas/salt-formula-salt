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
    pillar:
      engine: reclass
      data_dir: /srv/salt/reclass
    environment:
      prd:
        formula:
          memcached:
            source: git
            address: 'git@git.domain.com/memcached-formula.git'
            revision: master
