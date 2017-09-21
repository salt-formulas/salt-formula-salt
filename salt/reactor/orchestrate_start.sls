
orchestrate_orchestrate_run:
  runner.state.orchestrate:
  - mods: {{ data.data.orchestrate }}
  - queue: {{ data.data.get('queue', True) }}

