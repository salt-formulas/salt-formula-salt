
orchestrate_orchestrate_run:
  runner.state.orchestrate:
  - mods: salt://{{ data.data.orchestrate }}
  - queue: {{ data.data.get('queue', True) }}
