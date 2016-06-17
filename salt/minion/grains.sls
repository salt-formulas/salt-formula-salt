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
  file.touch:
  - name: /etc/salt/grains.d/placeholder
  - require:
    - file: salt_minion_grains_dir

salt_minion_grains_file:
  cmd.run:
  - name: cat /etc/salt/grains.d/* > /etc/salt/grains
  - require:
    - file: salt_minion_grains_placeholder
  - watch_in:
    - service: salt_minion_service

{%- endif %}
