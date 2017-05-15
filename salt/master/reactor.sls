{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

include:
- salt.master.service

/etc/salt/master.d/_reactor.conf:
  file.managed:
  - source: salt://salt/files/_reactor.conf
  - user: root
  - template: jinja
  - require:
    - {{ master.install_state }}
  - watch_in:
    - service: salt_master_service

{%- endif %}
