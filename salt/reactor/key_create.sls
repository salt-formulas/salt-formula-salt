
{% if data.data.orch_pre_create is defined %}

orchestrate_node_key_pre_create:
  runner.state.orchestrate:
  - mods: {{ data.data.orch_pre_create }}
  - queue: True
  - pillar: {{ data.data.get('orch_pre_create_pillar', {}) }}

{% endif %}

node_key_create:
  runner.state.orchestrate:
  - mods: salt.orchestrate.reactor.key_create
  - queue: True
  - pillar:
      node_id: {{ data.data['node_id'] }}
      node_host: {{ data.data['node_host'] }}

{% if data.data.orch_post_create is defined %}

orchestrate_node_key_post_create:
  runner.state.orchestrate:
  - mods: {{ data.data.orch_post_create }}
  - queue: True
  - pillar: {{ data.data.get('orch_post_create_pillar', {}) }}

{% endif %}
