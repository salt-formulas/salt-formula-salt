{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

salt_master_test_packages:
  pkg.latest:
  - names: {{ master.test_pkgs }}

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