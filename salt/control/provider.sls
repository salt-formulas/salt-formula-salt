{% from "salt/map.jinja" import control with context %}
{%- if control.enabled %}

/etc/salt/cloud.providers:
  file.managed:
  - source: salt://salt/files/providers.conf
  - user: root
  - group: root
  - template: jinja

/etc/salt/cloud.profiles:
  file.managed:
  - source: salt://salt/files/profiles.conf
  - user: root
  - group: root
  - template: jinja

{%- endif %}