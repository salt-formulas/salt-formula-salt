{%- from "salt/map.jinja" import syndic with context %}
{%- if syndic.enabled %}

include:
- salt.master.service

salt_syndic_packages:
  pkg.installed:
  - names: {{ syndic.pkgs }}

/etc/salt/master.d/_syndic.conf:
  file.managed:
  - source: salt://salt/files/_syndic.conf
  - user: root
  - template: jinja
  - watch_in:
    - service: salt_master_service

{%- endif %}
