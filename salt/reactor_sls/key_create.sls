{%- set node_id = salt['pillar.get']('node_id') %}
{%- set node_host = salt['pillar.get']('node_host') %}

key_create_{{ node_id }}:
  module.run:
    saltkey.key_create:
    - id_: {{ node_id }}
    - host: {{ node_host }}

