{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

{%- if master.pillar.engine == 'salt' %}

include:
- git.client
- salt.master.service

{{ master.pillar.source.address }}:
  git.latest:
  - target: /srv/salt/pillar
  - rev: {{ master.pillar.source.branch }}
  - require:
    - file: /srv/salt/env
    - pkg: git_packages

{%- if master.system is defined %}

/srv/salt/env/{{ master.system.environment }}/top.sls:
  file.symlink:
  - target: /srv/salt/pillar/files_top.sls
  - require:
    - file: /srv/salt/env/{{ master.system.environment }}

{%- endif %}

{%- elif master.pillar.engine == 'reclass' %}

include:
- reclass.storage.data

/srv/salt/reclass/classes/service:
  file.directory

{%- if master.system is defined %}

{%- for formula_name, formula in master.system.get('formula', {}).iteritems() %}

/srv/salt/reclass/classes/service/{{ formula_name }}:
  file.symlink:
  - target: /srv/salt/env/{{ master.system.environment }}/{{ formula_name }}/metadata/service
  - require:
    - git: reclass_data_source
    - file: /srv/salt/reclass/classes/service

{%- endfor %}

{%- else %}

{%- for environment_name, environment in master.environment.iteritems() %}

{%- for formula_name, formula in environment.get('formula', {}).iteritems() %}

{%- if environment_name == master.base_environment %}

/srv/salt/reclass/classes/service/{{ formula_name }}:
  file.symlink:
  {%- if formula.source == 'pkg' %}
  - target: /usr/share/salt-formulas/reclass/service/{{ formula_name }}
  {%- else %}
  - target: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}/metadata/service
  {%- endif %}
  - require:
    - git: reclass_data_source
    - file: /srv/salt/reclass/classes/service

{%- endif %}

{%- endfor %}

{%- endfor %}

{%- endif %}

{%- endif %}

{%- endif %}