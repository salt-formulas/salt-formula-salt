
orchestrate_node_install:
  runner.state.orchestrate:
  - mods: salt.reactor.orchestrate.node_install
  - queue: True
  - pillar:
      event_originator: {{ data.id }}

