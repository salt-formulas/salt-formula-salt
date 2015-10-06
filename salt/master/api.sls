{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

include:
- salt.master.service

salt_api_packages:
  pkg.latest
  - names:
    - salt-api
  - require:
    - pkg: salt_master_packages

salt_api_service:
  service.running:
  - name: salt-api
  - require:
    - pkg: salt_api_packages
  - watch:
    - file: /etc/salt/master

{%- endif %}
