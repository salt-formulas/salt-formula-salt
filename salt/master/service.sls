{%- from "salt/map.jinja" import master, renderer with context %}
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

{%- if master.cache is defined %}

/etc/salt/master.d/_{{ master.cache.plugin }}.conf:
  file.managed:
  - source: salt://salt/files/cache/_{{ master.cache.plugin }}.conf
  - user: root
  - template: jinja
  - require:
    - {{ master.install_state }}
  - watch_in:
    - service: salt_master_service

{%- endif %}

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

{%- if master.engine is defined %}

/etc/salt/master.d/_engine.conf:
  file.managed:
  - source: salt://salt/files/_engine.conf
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

{%- if renderer | length > 0 %}

/etc/salt/master.d/_renderer.conf:
  file.managed:
  - source: salt://salt/files/_renderer.conf
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
  - enable: True
  {%- if grains['saltversioninfo'][0] >= 2017 and grains['saltversioninfo'][1] >= 7 %}
  - retry:
    attempts: 2
    interval: 5
    splay: 5
  {%- endif %}

{%- if grains.get('init', None) == 'systemd' %}
salt_master_systemd_override:
  file.managed:
    - name: /etc/systemd/system/{{ master.service }}.service.d/50-restarts.conf
    - source: salt://salt/files/systemd/{{ master.service }}.service_50-restarts
    - makedirs: True

salt_master_systemd_reload:
  module.wait:
    - name: service.systemctl_reload
    - onchanges:
      - file: salt_master_systemd_override
    - watch_in:
      - service: salt_master_service
{%- endif %}

/srv/salt/env:
  file.directory:
  - user: root
  - mode: 755
  - makedirs: true

{%- endif %}
