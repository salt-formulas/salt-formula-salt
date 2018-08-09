{#- This state can be called explicitly. Do not include this file in minion.init #}
{%- from "salt/map.jinja" import minion,renderer with context %}
{%- if minion.enabled %}

{%- if minion.source.get('engine', 'pkg') == 'pkg' %}

salt_minion_packages:
  pkg.installed:
  - names: {{ minion.pkgs }}
  {%- if minion.source.version is defined %}
  - version: {{ minion.source.version }}
  {%- endif %}

salt_minion_dependency_packages:
  pkg.installed:
  - pkgs: {{ minion.dependency_pkgs }}

{%- elif minion.source.get('engine', 'pkg') == 'pip' %}

salt_minion_packages:
  pip.installed:
  - name: salt{% if minion.source.version is defined %}=={{ minion.source.version }}{% endif %}

salt_minion_dependency_packages:
  pkg.installed:
  - pkgs: {{ minion.dependency_pkgs_pip }}

{%- endif %}

/etc/salt/minion.d/minion.conf:
  file.managed:
  - source: salt://salt/files/minion.conf
  - user: root
  - group: root
  - mode: 600
  - template: jinja
  - require:
    - {{ minion.install_state }}

{%- if renderer | length > 0 %}

/etc/salt/minion.d/_renderer.conf:
  file.managed:
  - source: salt://salt/files/_renderer.conf
  - user: root
  - group: root
  - mode: 600
  - template: jinja
  - require:
    - {{ minion.install_state }}
  - watch_in:
    - service: salt_minion_service

{%- endif %}

salt_minion_service:
  service.running:
    - name: {{ minion.service }}
    - enable: true
    - require:
      - pkg: salt_minion_packages
      - pkg: salt_minion_dependency_packages
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

{#- Restart salt-minion if needed but after all states are executed #}
salt_minion_service_restart:
  cmd.run:
    - name: 'while true; do salt-call saltutil.running|grep fun: && continue; salt-call --local service.restart {{ minion.service }}; break; done'
    - shell: /bin/bash
    - bg: true
    - order: last
    - onchanges:
      - file: /etc/salt/minion.d/minion.conf
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}
    - require:
      - service: salt_minion_service

salt_minion_sync_all:
  module.run:
    - name: 'saltutil.sync_all'
    - onchanges:
      - service: salt_minion_service
    - require:
      - pkg: salt_minion_packages
      - pkg: salt_minion_dependency_packages

{%- endif %}
