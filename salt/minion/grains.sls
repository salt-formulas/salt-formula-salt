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

salt_minion_grains_files:
  file.managed:
  - names:
    - /etc/salt/grains
    - /etc/salt/grains.d/placeholder
  - replace: False
  - require:
    - file: salt_minion_grains_dir

{%- set new_grains = salt['cmd.run']('cat /etc/salt/grains.d/*') %}
{%- set old_grains = salt['cmd.run']('cat /etc/salt/grains') %}

{%- if new_grains != old_grains %}

salt_minion_grains_file:
  cmd.run:
  - name: cat /etc/salt/grains.d/* > /etc/salt/grains
  - require:
    - file: salt_minion_grains_files

salt_minion_grains_publish:
  module.run:
  - name: mine.update
  - require:
    - cmd: salt_minion_grains_file

{%- endif %}

{%- endif %}
