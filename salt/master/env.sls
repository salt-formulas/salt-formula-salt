{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

include:
- git.client
- salt.master.service

{%- if master.system is defined %}

salt_env_{{ master.system.environment }}_dirs_obsolete:
  file.directory:
  - names: 
    - /srv/salt/env/{{ master.system.environment }}/_modules
    - /srv/salt/env/{{ master.system.environment }}/_states
    - /srv/salt/env/{{ master.system.environment }}/_grains
    - /srv/salt/env/{{ master.system.environment }}
  - makedirs: True

{%- for grain_name, grain in master.system.get('grain', {}).iteritems() %}

{%- if grain.source == 'git' %}

salt_master_{{ master.system.environment }}_{{ grain_name }}_grain_source:
  git.latest:
  - name: {{ grain.address }}
  - target: /srv/salt/env/{{ master.system.environment }}/_extra/grain_{{ grain_name }}
  - rev: {{ grain.revision }}
  - require:
    - file: salt_env_{{ master.system.environment }}_dirs
    - pkg: git_packages

/srv/salt/env/{{ master.system.environment }}/_grains/{{ grain_name }}.py:
  file.symlink:
  - target: /srv/salt/env/{{ master.system.environment }}/_extra/grain_{{ grain_name }}/{{ grain_name }}.py
  - require:
    - git: salt_master_{{ master.system.environment }}_{{ grain_name }}_grain_source

{%- endif %}

{%- endfor %}

{%- for state_name, state in master.system.get('state', {}).iteritems() %}

{%- if state.source == 'git' %}

salt_master_{{ master.system.environment }}_{{ state_name }}_state_source:
  git.latest:
  - name: {{ state.address }}
  - target: /srv/salt/env/{{ master.system.environment }}/_extra/state_{{ state_name }}
  - rev: {{ state.revision }}
  - require:
    - file: salt_env_{{ master.system.environment }}_dirs
    - pkg: git_packages

/srv/salt/env/{{ master.system.environment }}/_modules/{{ state_name }}.py:
  file.symlink:
  - target: /srv/salt/env/{{ master.system.environment }}/_extra/state_{{ state_name }}/modules/{{ state_name }}.py
  - require:
    - git: salt_master_{{ master.system.environment }}_{{ state_name }}_state_source

/srv/salt/env/{{ master.system.environment }}/_states/{{ state_name }}.py:
  file.symlink:
  - target: /srv/salt/env/{{ master.system.environment }}/_extra/state_{{ state_name }}/states/{{ state_name }}.py
  - require:
    - git: salt_master_{{ master.system.environment }}_{{ state_name }}_state_source

{%- endif %}

{%- endfor %}

{%- for formula_name, formula in master.system.get('formula', {}).iteritems() %}

{%- if formula.source == 'git' %}

salt_master_{{ master.system.environment }}_{{ formula_name }}_formula_source:
  git.latest:
  - name: {{ formula.address }}
  - target: /srv/salt/env/{{ master.system.environment }}/{{ formula_name }}
  - rev: {{ formula.revision }}
  - require:
    - file: salt_env_{{ master.system.environment }}_dirs
    - pkg: git_packages

{%- endif %}

{%- endfor %}

{%- if master.system.returners is defined %}

salt_master_{{ master.system.environment }}_returners:
  git.latest:
  - name: {{ master.system.returners.address }}
  - target: /srv/salt/env/{{ master.system.environment }}/_returners
  - rev: {{ master.system.returners.revision }}
  - require:
    - file: salt_env_{{ master.system.environment }}_dirs
    - pkg: git_packages

{%- endif %}

{%- endif %}

{# Start new #}

{%- for environment_name, environment in master.get('environment', {}).iteritems() %}

{%- if master.base_environment == environment_name %}

salt_env_{{ environment_name }}_pre_dirs:
  file.directory:
  - names: 
    - /usr/share/salt-formulas/env/_modules
    - /usr/share/salt-formulas/env/_states
    - /usr/share/salt-formulas/env/_grains
    - /usr/share/salt-formulas/env/_formulas
  - makedirs: True

salt_env_{{ environment_name }}_dirs:
  file.symlink:
  - name: /srv/salt/env/{{ environment_name }}
  - target: /usr/share/salt-formulas/env
  - require:
    - file: salt_env_{{ environment_name }}_pre_dirs

{%- else %}

salt_env_{{ environment_name }}_dirs:
  file.directory:
  - names: 
    - /srv/salt/env/{{ environment_name }}/_modules
    - /srv/salt/env/{{ environment_name }}/_states
    - /srv/salt/env/{{ environment_name }}/_grains
    - /srv/salt/env/{{ environment_name }}/_formulas
  - makedirs: True

{%- endif %}

{%- for formula_name, formula in environment.get('formula', {}).iteritems() %}

{%- if formula.source == 'pkg' %}

salt_master_{{ environment_name }}_{{ formula.name }}_formula:
  pkg.latest:
  - name: {{ formula.name }}

{%- elif formula.source == 'git' %}

{%- if master.base_environment == environment_name %}

salt_master_{{ environment_name }}_{{ formula_name }}_formula:
  git.latest:
  - name: {{ formula.address }}
  - target: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}
  - rev: {{ formula.revision }}
  - require:
    - file: salt_env_{{ environment_name }}_dirs
    - pkg: git_packages

salt_env_{{ environment_name }}_{{ formula_name }}_link:
  file.symlink:
  - name: /usr/share/salt-formulas/env/{{ formula_name }}
  - target: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}/{{ formula_name }}
  - require:
    - file: salt_env_{{ environment_name }}_dirs

{%- for grain_name, grain in formula.get('grain', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ grain_name }}_grain:
  file.symlink:
  - name: /usr/share/salt-formulas/env/_grains/{{ grain_name }}
  - target: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}/_grains/{{ grain_name }}

{%- endfor %}

{%- for module_name, module in formula.get('module', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ module_name }}_module:
  file.symlink:
  - name: /usr/share/salt-formulas/env/_modules/{{ module_name }}
  - target: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}/_modules/{{ module_name }}

{%- endfor %}

{%- for state_name, state in formula.get('state', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ state_name }}_state:
  file.symlink:
  - name: /usr/share/salt-formulas/env/_states/{{ state_name }}
  - target: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}/_states/{{ state_name }}

{%- endfor %}

{%- else %}

salt_master_{{ environment_name }}_{{ formula_name }}_formula:
  git.latest:
  - name: {{ formula.address }}
  - target: /srv/salt/env/{{ environment_name }}/_formulas/{{ formula_name }}
  - rev: {{ formula.revision }}
  - require:
    - file: salt_env_{{ environment_name }}_dirs
    - pkg: git_packages

salt_env_{{ environment_name }}_{{ formula_name }}_link:
  file.symlink:
  - name: /srv/salt/env/{{ environment_name }}/{{ formula_name }}
  - target: /srv/salt/env/{{ environment_name }}/_formulas/{{ formula_name }}/{{ formula_name }}
  - require:
    - file: salt_env_{{ environment_name }}_dirs

{%- for grain_name, grain in formula.get('grain', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ grain_name }}_grain:
  file.symlink:
  - name: /srv/salt/env/{{ environment_name }}/_grains/{{ grain_name }}
  - target: /srv/salt/env/{{ environment_name }}/_formulas/{{ formula_name }}/_grains/{{ grain_name }}

{%- endfor %}

{%- for module_name, module in formula.get('module', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ module_name }}_module:
  file.symlink:
  - name: /srv/salt/env/{{ environment_name }}/_grains/{{ module_name }}
  - target: /srv/salt/env/{{ environment_name }}/_formulas/{{ formula_name }}/_grains/{{ module_name }}

{%- endfor %}

{%- for state_name, state in formula.get('state', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ state_name }}_state:
  file.symlink:
  - name: /srv/salt/env/{{ environment_name }}/_grains/{{ state_name }}
  - target: /srv/salt/env/{{ environment_name }}/_formulas/{{ formula_name }}/_grains/{{ state_name }}

{%- endfor %}

{%- endif %}

{%- endif %}

{%- endfor %}

{%- endfor %}

{# end new #}

{%- endif %}