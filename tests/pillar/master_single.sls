git:
  client:
    enabled: true
linux:
  system:
    enabled: true
salt:
  master:
    enabled: true
    command_timeout: 5
    worker_threads: 2
    base_environment: prd
    pillar:
      engine: salt
      source:
        engine: git
        address: 'git@repo.domain.com:salt/pillar-demo.git'
        branch: 'master'
    environment:
      prd:
        formula:
          memcached:
            source: git
            address: 'git@git.domain.com/memcached-formula.git'
            revision: master
