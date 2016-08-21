git:
  client:
    enabled: true
linux:
  system:
    enabled: true
salt:
  master:
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
    handler:
      handler01:
        engine: udp
        bind:
          host: 127.0.0.1
          port: 9999
