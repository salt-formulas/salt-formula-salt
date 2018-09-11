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

{%- if cluster.enable_vnc is defined and cluster.enable_vnc %}
{%- set enable_vnc = True %}
{%- else %}
{%- set enable_vnc = False %}
{%- endif %}


{%- for node_name, node in cluster.node.iteritems() %}

{%- if node.name is defined %}
{%- set node_name = node.name %}
{%- endif %}

{%- if node.provider == grains.id %}

{%- set size = control.size.get(node.size) %}
{%- set seed = node.get('seed', cluster.get('seed', True)) %}
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
  {%- if node.rng is defined %}
  - rng: {{  node.rng }}
  {%- elif rng is defined %}
  - rng: {{ rng }}
  {%- endif %}
  {%- if node.loader is defined %}
  - loader: {{  node.loader }}
  {%- endif %}
  {%- if node.machine is defined %}
  - machine: {{ node.machine }}
  {%- endif %}
  {%- if node.cpuset is defined %}
  - cpuset: {{ node.cpuset }}
  {%- endif %}
  {%- if node.cpu_mode is defined %}
  - cpu_mode: {{ node.cpu_mode }}
  {%- endif %}
  - kwargs:
      {%- if cluster.config is defined %}
      config: {{ cluster.config }}
      {%- endif %}
      {%- if cloud_init and cloud_init.get('enabled', True) %}
      cloud_init: {{ cloud_init }}
      {%- endif %}
      {%- if seed %}
      seed: {{ seed }}
      {%- endif %}
      serial_type: pty
      console: True
      {%- if node.enable_vnc is defined %}
      enable_vnc: {{ node.enable_vnc }}
      {%- else %}
      enable_vnc: {{ enable_vnc }}
      {%- endif %}
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
