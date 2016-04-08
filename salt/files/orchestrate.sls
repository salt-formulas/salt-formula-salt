{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

{{ formula_dict }}

{%- for environment_name, environment in master.get('environment', {}).iteritems() %}

{%- if master.base_environment == environment_name %}

{%- set formula_dict = environment.get('formula', {}) %}
{%- set new_formula_dict = {} %}

{%- for formula_name, formula in formula_dict.iteritems() %}

{%- set _tmp = new_formula_dict.update({formula_name: formula.get('orchestrate_order', 100)}) %}

{%- endfor %}

{%- set sorted_formula_list = new_formula_dict|dictsort(false, 'value') %}
	
{%- for formula in sorted_formula_list %}

{%- if salt['file.file_exists']('/srv/salt/env/'+environment_name+'/'+formula.0+'/orchestrate.sls') %}

{{ salt['cmd.run']('cat /srv/salt/env/'+environment_name+'/'+formula.0+'/orchestrate.sls') }}

{%- else %}

{{ formula.0 }}:
  salt.state:
    - tgt: 'services:{{ formula.0 }}'
    - tgt_type: grain
    - sls: {{ formula.0 }}

{%- endif %}

{%- endfor %}

{%- endif %}

{%- endfor %}

{%- endif %}