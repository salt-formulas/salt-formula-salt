{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

include:
- salt.master.service

/etc/salt/roster:
  file.managed:
  - source: salt://salt/files/roster
  - user: root
  - template: jinja
  - require:
    - {{ master.install_state }}
  - watch_in:
    - service: salt_master_service

{%- endif %}