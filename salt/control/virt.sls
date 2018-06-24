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

salt_libvirt_service:
  service.running:
  - name: {{ control.virt_service }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

##Posibility to disable rng device globally for old libvirt version
{%- if cluster.rng is defined %}
{%- set rng = cluster.rng %}
{%- endif %}

{%- for node_name, node in cluster.node.iteritems() %}

{%- if node.name is defined %}
{%- set node_name = node.name %}
{%- endif %}

{%- if node.provider == grains.id %}

{%- set size = control.size.get(node.size) %}
{%- set cluster_cloud_init = cluster.get('cloud_init', {}) %}
{%- set node_cloud_init = node.get('cloud_init', {}) %}
{%- set cloud_init = salt['grains.filter_by']({'default': cluster_cloud_init}, merge=node_cloud_init) %}

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
  {%- if  node.rng is defined %}
  - rng: {{  node.rng }}
  {%- elif rng is defined %}
  - rng: {{ rng }}
  {%- endif %}
  {%- if  node.loader is defined %}
  - loader: {{  node.loader }}
  {%- endif %}
  {%- if  node.machine is defined %}
  - machine: {{ node.machine }}
  {%- endif %}
  {%- if  node.cpu_mode is defined %}
  - cpu_mode: {{ node.cpu_mode }}
  {%- endif %}
  - kwargs:
      {%- if cloud_init is defined %}
      cloud_init: {{ cloud_init }}
      {%- endif %}
      seed: True
      serial_type: pty
      console: True
      {%- if node.img_dest is defined %}
      img_dest: {{ node.img_dest }}
      {%- endif %}
      {%- if node.mac is defined %}
      {%- for mac_name, mac in node.mac.items() %}
      {{ mac_name }}_mac: {{ mac }}
      {%- endfor %}
      {%- endif %}
  - unless: virsh list --all --name| grep -E "^{{ node_name }}.{{ cluster.domain }}$"
  - require:
    - salt_libvirt_service

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
