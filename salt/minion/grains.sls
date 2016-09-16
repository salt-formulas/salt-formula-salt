{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

include:
- salt.minion.service

salt_minion_grains_dir:
  file.directory:
  - name: /etc/salt/grains.d
  - mode: 700
  - makedirs: true
  - user: root
  - require:
    - {{ minion.install_state }}

salt_minion_grains_placeholder:
  file.managed:
  - name: /etc/salt/grains.d/placeholder
  - replace: false
  - require:
    - file: salt_minion_grains_dir

{#
  TODO: we need to be idempotent but reload salt-minion when grains are
  changed. So for now, adding new grains requires removal of /etc/salt/grains
  file and execution of salt state again
  This can be possibly solved by custom module for grains management or native
  support for grains.d in salt
#}
salt_minion_grains_file:
  cmd.run:
  - name: cat /etc/salt/grains.d/* > /etc/salt/grains
  - creates: /etc/salt/grains
  - require:
    - file: salt_minion_grains_placeholder
  - watch_in:
    - service: salt_minion_service

salt_minion_grains_publish:
  module.wait:
  - name: mine.send
  - name: grains.items
  - watch:
    - service: salt_minion_service
    - cmd: salt_minion_grains_file

{%- endif %}
