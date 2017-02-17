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
    ssh:
      minion:
        node01:
          host: 10.0.0.1
          user: root
          password: password
          port: 22
