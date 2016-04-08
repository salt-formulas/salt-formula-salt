{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

salt_minion_packages:
  pkg.latest:
  - names: {{ minion.pkgs }}

/etc/salt/minion.d/minion.conf:
  file.managed:
  - source: salt://salt/files/minion.conf
  - user: root
  - group: root
  - template: jinja
  - require:
    - pkg: salt_minion_packages
  - watch_in:
    - service: salt_minion_service

salt_minion_service:
  service.running:
  - name: {{ minion.service }}
  - enable: true

{%- endif %}