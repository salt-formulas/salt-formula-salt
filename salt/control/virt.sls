{% from "salt/map.jinja" import control with context %}
{%- if control.enabled and control.virt_enabled is defined %}

salt_control_virt_packages:
  pkg.installed:
    - names: {{ control.virt_pkgs }}

{%- for package in control.virt_pips %}

{{ package }}:
  pip.installed:
  - require:
    - pkg: salt_control_virt_packages

{%- endfor %}

{%- for cluster_name, cluster in control.cluster.iteritems() %}

{%- if cluster.engine == "virt" %}

{%- for node_name, node in cluster.node.iteritems() %}

{%- set size = control.size.get(node.size) %}

salt_control_virt_{{ cluster_name }}_{{ node_name }}:
  module.run:
  - name: virt.init
  - m_name: {{ node_name }}_{{ cluster.domain }}
  - cpu: {{ size.cpu }}
  - mem: {{ size.ram }}
  - image: salt://{{ node.image }}

{%- endfor %}

{%- endif %}

{%- endfor %}

{%- endif %}
