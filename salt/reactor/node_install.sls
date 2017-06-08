
orchestrate_node_install:
  runner.state.orchestrate:
    - mods: salt://salt/orchestrate/node_install.sls
    - queue: True
    - pillar:
        event_originator: {{ data.id }}
