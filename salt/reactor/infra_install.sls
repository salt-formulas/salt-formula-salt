
orchestrate_infra_install:
  runner.state.orchestrate:
    - mods: salt://salt/orchestrate/infra_install.sls
    - queue: True
