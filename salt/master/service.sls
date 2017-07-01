{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

{%- if master.source.get('engine', 'pkg') == 'pkg' %}

salt_master_packages:
  pkg.installed:
  - names: {{ master.pkgs }}
  {%- if master.source.version is defined %}
  - version: {{ master.source.version }}
  {%- endif %}

{%- elif master.source.get('engine', 'pkg') == 'pip' %}

salt_master_packages:
  pip.installed:
  - name: salt{% if master.source.version is defined %}=={{ master.source.version }}{% endif %}

{%- endif %}

/etc/salt/master.d/master.conf:
  file.managed:
  - source: salt://salt/files/master.conf
  - user: root
  - template: jinja
  - require:
    - {{ master.install_state }}
  - watch_in:
    - service: salt_master_service

{%- if master.user is defined %}

/etc/salt/master.d/_acl.conf:
  file.managed:
  - source: salt://salt/files/_acl.conf
  - user: root
  - template: jinja
  - require:
    - {{ master.install_state }}
  - watch_in:
    - service: salt_master_service

{%- endif %}

{%- if master.peer is defined %}

/etc/salt/master.d/_peer.conf:
  file.managed:
  - source: salt://salt/files/_peer.conf
  - user: root
  - template: jinja
  - require:
    - {{ master.install_state }}
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
