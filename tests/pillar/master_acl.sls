git:
  client:
    enabled: true
linux:
  system:
    enabled: true
salt:
  master:
    command_timeout: 5
    worker_threads: 3
    enabled: true
    source:
      engine: pkg
    pillar:
      engine: salt
      source:
        engine: local
    environment:
      prd:
        formula: {}
    user:
      peter:
        enabled: true
        permissions:
        - 'fs.fs'
        - 'fs.\*'
