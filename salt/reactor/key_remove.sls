
{% if data.data.orch_pre_remove is defined %}

orchestrate_node_key_pre_remove:
  runner.state.orchestrate:
  - mods: {{ data.data.orch_pre_remove }}
  - queue: True
  - pillar: {{ data.data.get('orch_pre_remove_pillar', {}) }}

{% endif %}

node_key_remove:
  runner.state.orchestrate:
  - mods: salt.orchestrate.reactor.key_remove.sls
  - queue: True
  - pillar:
      node_id: {{ data.data['node_id'] }}

{% if data.data.orch_post_remove is defined %}

orchestrate_node_key_post_remove:
  runner.state.orchestrate:
  - mods: {{ data.data.orch_post_remove }}
  - queue: True
  - pillar: {{ data.data.get('orch_post_remove_pillar', {}) }}

{% endif %}
