{%- set node_id = salt['pillar.get']('node_id') %}
{%- set node_host = salt['pillar.get']('node_host') %}

linux_state_all_nodes:
  salt.state:
    - tgt: 'salt:master'
    - tgt_type: pillar
    - sls: salt.reactor_sls.key_create
    - queue: True
    - pillar:
        node_id: {{ node_id }}
        node_host: {{ node_host }}

