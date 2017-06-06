
orchestrate_orchestrate_start:
  runner.state.orchestrate:
    - mods: salt://{{ data.data.orchestrate }}
    - queue: {{ data.data.get('queue', True) }}
