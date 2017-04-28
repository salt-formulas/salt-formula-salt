{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

include:
- salt.minion.service

salt_minion_grains_dir:
  file.directory:
  - name: /etc/salt/grains.d
  - mode: 700
  - makedirs: true
  - user: root
  - require:
    - {{ minion.install_state }}

salt_minion_grains_files:
  file.managed:
  - names:
    - /etc/salt/grains
    - /etc/salt/grains.d/placeholder
  - replace: False
  - require:
    - file: salt_minion_grains_dir

salt_minion_grains_pkg_validity_check:
  pkg.installed:
  - pkgs: {{ minion.grains_validity_pkgs }}

{%- for service_name, service in pillar.items() %}
  {%- set support_fragment_file = service_name+'/meta/salt.yml' %}
  {%- macro load_support_file() %}{% include support_fragment_file ignore missing %}{% endmacro %}
  {%- set support_yaml = load_support_file()|load_yaml %}

  {%- if support_yaml %}
    {%- for name, grain in support_yaml.get('grain', {}).iteritems() %}
salt_minion_grain_{{ service_name }}_{{ name }}:
  file.managed:
    - name: /etc/salt/grains.d/{{ name }}
    - contents: |
        {{ grain|yaml(False)|indent(8) }}
    - require:
      - file: salt_minion_grains_dir

salt_minion_grain_{{ service_name }}_{{ name }}_validity_check:
  cmd.wait:
    - name: python -c "import yaml; stream = file('/etc/salt/grains.d/{{ name }}', 'r'); yaml.load(stream); stream.close()"
    - require:
      - pkg: salt_minion_grains_pkg_validity_check
    - watch:
      - file: salt_minion_grain_{{ service_name }}_{{ name }}
    - watch_in:
      - cmd: salt_minion_grains_file
    {%- endfor %}
  {%- endif %}
{%- endfor %}

salt_minion_grains_file:
  cmd.wait:
  - name: cat /etc/salt/grains.d/* > /etc/salt/grains
  - require:
    - file: salt_minion_grains_files

salt_minion_grains_publish:
  module.wait:
  - name: mine.update
  - watch:
    - cmd: salt_minion_grains_file

{%- endif %}
