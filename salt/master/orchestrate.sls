{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

{%- for environment_name, environment in master.get('environment', {}).iteritems() %}

{%- if master.base_environment == environment_name %}

{%- set formula_dict = {} %}
{%- for formula_name, formula in formula_dict.iteritems() %}

{%- if salt['file.file_exists']('salt://'+formula_name+'/meta/salt.yml') %}
{%- set grains_fragment_file = formula_name+'/meta/salt.yml' %}
{%- macro load_grains_file() %}{% include grains_fragment_file %}{% endmacro %}
{%- set grains_yaml = load_grains_file()|load_yaml %}
{% _dummy = formula_dict.update{formula_name: grains_yaml.orchestrate }}
{%- else %}
{%- endif %}
{%- endfor %}

/srv/salt/env/{{ environment_name}}/orchestrate.sls:
  file.managed:
  - source: salt://salt/files/orchestrate.sls
  - user: root
  - template: jinja
  - defaults:
      formula_dict: {{ formula_dict|yaml }}

{%- endif %}

{%- endfor %}

{%- endif %}