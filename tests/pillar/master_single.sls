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
    environment:
      prd:
        formula:
          memcached:
            source: git
            address: 'git@git.domain.com/memcached-formula.git'
            revision: master
