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

{%- for service_name, service in pillar.items() %}
    {%- set support_fragment_file = service_name+'/meta/salt.yml' %}
    {%- macro load_support_file() %}{% include support_fragment_file ignore missing %}{% endmacro %}
    {%- set support_yaml = load_support_file()|load_yaml %}

    {%- if support_yaml and support_yaml.get('minion', {}) %}
      {%- for name, conf in support_yaml.get('minion', {}).iteritems() %}
salt_minion_config_{{ service_name }}_{{ name }}:
  file.managed:
    - name: /etc/salt/minion.d/_{{ name }}.conf
    - user: root
    - group: root
    - mode: 600
    - contents: |
        {{ conf|yaml(False)|indent(8) }}
    - require:
      - {{ minion.install_state }}

salt_minion_config_{{ service_name }}_{{ name }}_validity_check:
  cmd.run:
    - name: python -c "import yaml; stream = file('/etc/salt/minion.d/_{{ name }}.conf', 'r'); yaml.load(stream); stream.close()"
    - onchanges:
      - file: salt_minion_config_{{ service_name }}_{{ name }}
    - onchanges_in:
      - cmd: salt_minion_service_restart
      {%- endfor %}
    {%- endif %}

    {%- if support_yaml %}
    {%- set dependency = support_yaml.get('dependency') %}
    {%- if dependency %}
      {%- if dependency.get('engine', 'pkg') == 'pkg' %}

salt_minion_{{ service_name }}_dependencies:
  pkg.installed:
    - names: {{ dependency.get('pkgs') }}
    - onchanges_in:
      - cmd: salt_minion_service_restart
      {%- elif dependency.get('engine', 'pkg') == 'pip' %}
        {%- if dependency.get('pkgs') %}
salt_minion_{{ service_name }}_dependencies:
  pkg.installed:
    - names: {{ dependency.get('pkgs') }}
    - onchanges_in:
      - cmd: salt_minion_service_restart
    - require_in:
      - pip: salt_minion_{{ service_name }}_dependencies_pip
        {%- endif %}

salt_minion_{{ service_name }}_dependencies_pip:
  pip.installed:
    - names: {{ dependency.get('python_pkgs') }}
    - onchanges_in:
      - cmd: salt_minion_service_restart

      {%- endif %}
    {%- endif %}
    {%- endif %}
{%- endfor %}


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
