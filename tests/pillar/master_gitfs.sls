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
        engine: local
    gitfs_remotes:
      xccdf_benchmarks:
        url: https://gerrit.mcp.mirantis.net/oscore-tools/xccdf-benchmarks.git
        enabled: true
        params:
          base: master
