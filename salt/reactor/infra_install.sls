
orchestrate_infra_install:
  runner.state.orchestrate:
  - mods: salt.orchestrate.reactor.infra_install
  - queue: True

