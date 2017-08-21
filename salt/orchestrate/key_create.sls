{%- set node_name = salt['pillar.get']('node_name') %}

key_create_{{ node_name }}:
  salt.wheel:
  - name: key.gen_accept
  - id_: {{ node_name }}
