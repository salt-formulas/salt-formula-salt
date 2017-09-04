{%- set node_id = salt['pillar.get']('node_id') %}

linux_state_all_nodes:
  salt.state:
    - tgt: 'salt:master'
    - tgt_type: pillar
    - sls: salt.reactor_sls.key_remove
    - queue: True
    - pillar:
        node_id: {{ node_id }}

