{% from "salt/map.jinja" import control with context %}
{%- if control.enabled and control.virt_enabled is defined %}

salt_control_virt_packages:
  pkg.installed:
    - names: {{ control.virt_pkgs }}
{#
{%- for package in control.virt_pips %}

{{ package }}:
  pip.installed:
  - require:
    - pkg: salt_control_virt_packages

{%- endfor %}
#}
{%- for cluster_name, cluster in control.cluster.iteritems() %}

{%- if cluster.engine == "virt" %}

{%- for node_name, node in cluster.node.iteritems() %}

{%- if node.provider == grains.id %}

{%- set size = control.size.get(node.size) %}

salt_control_virt_{{ cluster_name }}_{{ node_name }}:
  module.run:
  - name: virt.init
  - m_name: {{ node_name }}.{{ cluster.domain }}
  - cpu: {{ size.cpu }}
  - mem: {{ size.ram }}
  - image: salt://{{ node.image }}
  - start: True
  - disk: {{ node.disk_profile }}
  - nic: {{ node.net_profile }} 
  - kwargs:
      seed: True
  - unless: virsh list --all | grep {{ node_name }}.{{ cluster.domain }}

#salt_control_seed_{{ cluster_name }}_{{ node_name }}:
#  module.run:
#  - name: seed.apply
#  - path: /srv/salt-images/{{ node_name }}.{{ cluster.domain }}/system.qcow2
#  - id_: {{ node_name }}.{{ cluster.domain }}
#  - unless: virsh list | grep {{ node_name }}.{{ cluster.domain }}
  

{%- endif %}

{%- endfor %}

{%- endif %}

{%- endfor %}

{%- endif %}
