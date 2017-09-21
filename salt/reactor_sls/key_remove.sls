{%- set node_id = salt['pillar.get']('node_id') %}

key_create_{{ node_id }}:
  salt.wheel:
  - name: key.delete
  - match: {{ node_id }}
