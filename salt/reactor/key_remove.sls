
{% if data.data.orch_pre_remove is defined %}

orchestrate_node_key_pre_remove:
  runner.state.orchestrate:
  - mods: salt://{{ data.data.orch_pre_remove }}
  - queue: True
  - pillar:
      node_name: {{ data.data['node_name'] }}

{% endif %}

node_key_remove:
  runner.state.orchestrate:
  - mods: salt://salt/orchestrate/key_remove.sls
  - queue: True
  - pillar:
      node_name: {{ data.data['node_name'] }}

{% if data.data.orch_post_remove is defined %}

orchestrate_node_key_post_remove:
  runner.state.orchestrate:
  - mods: salt://{{ data.data.orch_post_remove }}
  - queue: True
  - pillar:
      node_name: {{ data.data['node_name'] }}

{% endif %}
