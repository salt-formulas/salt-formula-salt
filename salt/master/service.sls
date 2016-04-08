{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

salt_master_packages:
  pkg.latest:
  - names: {{ master.pkgs }}

/etc/salt/master.d/master.conf:
  file.managed:
  - source: salt://salt/files/master.conf
  - user: root
  - template: jinja
  - require:
    - pkg: salt_master_packages
  - watch_in:
    - service: salt_master_service

{%- if master.peer is defined %}

/etc/salt/master.d/_peer.conf:
  file.managed:
  - source: salt://salt/files/_peer.conf
  - user: root
  - template: jinja
  - require:
    - pkg: salt_master_packages
  - watch_in:
    - service: salt_master_service

{%- endif %}

salt_master_service:
  service.running:
  - name: {{ master.service }}
  - enable: true

/srv/salt/env:
  file.directory:
  - user: root
  - mode: 755
  - makedirs: true

{%- endif %}