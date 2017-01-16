{%- from "salt/map.jinja" import api with context %}
{%- if api.get('enabled', False) %}

salt_api_packages:
  pkg.installed:
  - names: {{ api.pkgs }}

/etc/salt/master.d/_api.conf:
  file.managed:
  - source: salt://salt/files/_api.conf
  - user: root
  - template: jinja
  - require:
    - pkg: salt_api_packages
  - watch_in:
    - service: salt_api_service

salt_api_service:
  service.running:
  - name: salt-api
  - require:
    - pkg: salt_api_packages
  - watch:
    - file: /etc/salt/master.d/_api.conf

{%- endif %}
