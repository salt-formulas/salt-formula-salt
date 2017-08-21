
{% if data.data.orch_pre_create is defined %}

orchestrate_node_key_pre_create:
  runner.state.orchestrate:
  - mods: salt://{{ data.data.orch_pre_create }}
  - queue: True
  - pillar:
      node_name: {{ data.data['node_name'] }}

{% endif %}

node_key_create:
  runner.state.orchestrate:
  - mods: salt://salt/orchestrate/key_create.sls
  - queue: True
  - pillar:
      node_name: {{ data.data['node_name'] }}

{% if data.data.orch_post_create is defined %}

orchestrate_node_key_post_create:
  runner.state.orchestrate:
  - mods: salt://{{ data.data.orch_post_create }}
  - queue: True
  - pillar:
      node_name: {{ data.data['node_name'] }}

{% endif %}
