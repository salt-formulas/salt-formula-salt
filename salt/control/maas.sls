{% from "salt/map.jinja" import control with context %}
{%- if control.enabled and control.maas_enabled is defined %}

salt_control_maas_packages:
  pkg.installed:
    - names: {{ control.maas_pkgs }}

{%- for cluster_name, cluster in control.cluster.iteritems() %}

{%- if cluster.engine == "maas" %}

{%- for node_name, node in cluster.node.iteritems() %}

{# TODO: mass.server_active implementation #}

{%- endfor %}

{%- endif %}

{%- endfor %}

{%- endif %}
