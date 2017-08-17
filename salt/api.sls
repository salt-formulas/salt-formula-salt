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

{%- if api.get('ssl', {}).authority is defined %}

{%- set cert_file = "/etc/ssl/certs/" + api.ssl.get('name', grains.id) + ".crt" %}
{%- set ca_file = "/etc/ssl/certs/ca-" + api.ssl.authority + ".crt" %}

salt_api_init_tls:
  cmd.run:
  - name: "cat {{ cert_file }} {{ ca_file }} > /etc/ssl/certs/{{ api.ssl.get('name', grains.id) }}-chain.crt"
  - creates: /etc/ssl/certs/{{ api.ssl.get('name', grains.id) }}-chain.crt
  - watch_in:
    - service: salt_api_service

{%- endif %}

salt_api_service:
  service.running:
  - name: salt-api
  - require:
    - pkg: salt_api_packages
  - watch:
    - file: /etc/salt/master.d/_api.conf

{%- endif %}