{% from "salt/map.jinja" import control with context %}
{%- if control.enabled and control.virt_enabled is defined %}

include:
- salt.minion

salt_control_virt_packages:
  pkg.installed:
    - names: {{ control.virt_pkgs }}

{% if grains.oscodename == 'trusty' %}
{#- This tool is not available in newer releases #}
update-guestfs-appliance:
  cmd.wait:
    - watch:
      - pkg: salt_control_virt_packages
{%- endif %}

{%- for cluster_name, cluster in control.cluster.iteritems() %}

{%- if cluster.engine == "virt" %}

{%- for node_name, node in cluster.node.iteritems() %}

{%- if node.name is defined %}
{%- set node_name = node.name %}
{%- endif %}

{%- if node.provider == grains.id %}

{%- set size = control.size.get(node.size) %}

salt_control_virt_{{ cluster_name }}_{{ node_name }}:
  module.run:
  - name: virtng.init
  - m_name: {{ node_name }}.{{ cluster.domain }}
  - cpu: {{ size.cpu }}
  - mem: {{ size.ram }}
  - image: {{ node.image }}
  - start: True
  - disk: {{ size.disk_profile }}
  - nic: {{ size.net_profile }}
  - kwargs:
      seed: True
      serial_type: pty
      console: True
  - unless: virsh list --all --name| grep -E "^{{ node_name }}.{{ cluster.domain }}$"

#salt_control_seed_{{ cluster_name }}_{{ node_name }}:
#  module.run:
#  - name: seed.apply
#  - path: /srv/salt-images/{{ node_name }}.{{ cluster.domain }}/system.qcow2
#  - id_: {{ node_name }}.{{ cluster.domain }}
#  - unless: virsh list | grep {{ node_name }}.{{ cluster.domain }}

{%- if node.get("autostart", True) %}

salt_virt_autostart_{{ cluster_name }}_{{ node_name }}:
  module.run:
  - name: virt.set_autostart
  - vm_: {{ node_name }}.{{ cluster.domain }}
  - state: true
  - unless: virsh list --autostart --name| grep -E "^{{ node_name }}.{{ cluster.domain }}$"
  
{%- endif %}
  
{%- endif %}

{%- endfor %}

{%- endif %}

{%- endfor %}

{%- endif %}
