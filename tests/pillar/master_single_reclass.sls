salt:
  master:
    enabled: true
    command_timeout: 5
    worker_threads: 2
    base_environment: prd
    pillar:
      engine: reclass
      data_dir: /srv/salt/reclass
