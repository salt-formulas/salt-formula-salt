{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

{%- if minion.source.get('engine', 'pkg') == 'pkg' %}

salt_minion_packages:
  pkg.installed:
  - names: {{ minion.pkgs }}
  {%- if minion.source.version is defined %}
  - version: {{ minion.source.version }}
  {%- endif %}

{%- elif minion.source.get('engine', 'pkg') == 'pip' %}

salt_minion_packages:
  pip.installed:
  - name: salt{% if minion.source.version is defined %}=={{ minion.source.version }}{% endif %}

{%- endif %}

/etc/salt/minion.d/minion.conf:
  file.managed:
  - source: salt://salt/files/minion.conf
  - user: root
  - group: root
  - template: jinja
  - require:
    - {{ minion.install_state }}
  - watch_in:
    - service: salt_minion_service

{%- for service_name, service in pillar.items() %}
    {%- set support_fragment_file = service_name+'/meta/salt.yml' %}
    {%- macro load_support_file() %}{% include support_fragment_file ignore missing %}{% endmacro %}
    {%- set support_yaml = load_support_file()|load_yaml %}

    {%- if support_yaml and support_yaml.get('minion', {}) %}
      {%- for name, conf in support_yaml.get('minion', {}).iteritems() %}
salt_minion_config_{{ service_name }}_{{ name }}:
  file.managed:
    - name: /etc/salt/minion.d/_{{ name }}.conf
    - contents: |
        {{ conf|yaml(False)|indent(8) }}
    - watch_in:
      - cmd: salt_minion_service_restart
    - require:
      - {{ minion.install_state }}

salt_minion_config_{{ service_name }}_{{ name }}_validity_check:
  cmd.wait:
    - name: python -c "import yaml; stream = file('/etc/salt/minion.d/_{{ name }}.conf', 'r'); yaml.load(stream); stream.close()"
    - watch:
      - file: salt_minion_config_{{ service_name }}_{{ name }}
    - require_in:
      - cmd: salt_minion_service_restart
      {%- endfor %}
    {%- endif %}
{%- endfor %}

salt_minion_service:
  service.running:
  - name: {{ minion.service }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

{#- Restart salt-minion if needed but after all states are executed #}
salt_minion_service_restart:
  cmd.wait:
    - name: 'while true; do salt-call saltutil.running|grep fun: && continue; salt-call --local service.restart {{ minion.service }}; break; done'
    - shell: /bin/bash
    - bg: true
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}
    - require:
      - service: salt_minion_service

salt_minion_sync_all:
  module.run:
    - name: 'saltutil.sync_all'
    - watch:
      - service: salt_minion_service

{%- endif %}
