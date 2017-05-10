{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

{%- if minion.source.get('engine', 'pkg') == 'pkg' %}

salt_minion_packages:
  pkg.latest:
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
  - template: jinja
  - require:
    - {{ minion.install_state }}
  {%- if not grains.get('noservices', False) %}
  - watch_in:
    - service: salt_minion_service
  {%- endif %}

{%- if not grains.get('noservices', False) %}
salt_minion_service:
  service.running:
  - name: {{ minion.service }}
  - enable: true
  - require:
    - pkg: salt_minion_packages
    - pkg: salt_minion_dependency_packages
{%- endif %}

salt_minion_sync_all:
  module.run:
    - name: 'saltutil.sync_all'
  {%- if not grains.get('noservices', False) %}
    - watch:
      - service: salt_minion_service
  {%- endif %}
    - require:
      - pkg: salt_minion_packages
      - pkg: salt_minion_dependency_packages

{%- endif %}
