git:
  client:
    enabled: true
linux:
  system:
    enabled: true
salt:
  master:
    command_timeout: 5
    worker_threads: 2
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
  api:
    enabled: true
    ssl:
      engine: salt
    bind:
      address: 0.0.0.0
      port: 8000
