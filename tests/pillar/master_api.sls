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
    reactor_worker_threads: 2
    enabled: true
    source:
      engine: pkg
    pillar:
      engine: salt
      source:
        engine: local
    ext_pillars:
      1:
        module: cmd_json
        params: '"echo {\"arg\": \"val\"}"'
      2:
        module: cmd_yaml
        params: /usr/local/bin/get_yml.sh
    environment:
      prd:
        formula: {}
  api:
    enabled: true
    rest_timeout: 7200
    ssl:
      engine: salt
    bind:
      address: 0.0.0.0
      port: 8000
