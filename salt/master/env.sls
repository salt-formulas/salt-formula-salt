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

{%- set _formula_pkgs = [] %}
{%- set _formula_pkgs_with_version = [] %}
{%- for formula_name, formula in environment.get('formula', {}).iteritems() %}
{%- if formula.source == 'pkg' %}
{%- if formula.version is defined %}
{%- do _formula_pkgs_with_version.append(formula) %}
{%- else %}
{%- do _formula_pkgs.append(formula.name) %}
{%- endif %}
{%- endif %}
{%- endfor %}

{% if _formula_pkgs|length > 1 %}
salt_master_{{ environment_name }}_pkg_formulas:
  pkg.latest:
  - pkgs:
{%- for  pkg in _formula_pkgs %}
    - {{ pkg }}
{%- endfor %}
  - refresh: True
  - cache_valid_time: 300
{% endif %}

{% if _formula_pkgs_with_version|length > 1 %}
{%- for formula in _formula_pkgs_with_version %}
salt_master_{{ environment_name }}_pkg_formula_{{ formula.name }}:
{%- if formula.version == 'latest' %}
 pkg.latest:
  - refresh: True
  - cache_valid_time: 300
{%- elif formula.version == 'purged' %}
 pkg.purged:
{%- elif formula.version == 'removed' %}
 pkg.removed:
{%- else %}
 pkg.installed:
  - version: {{ formula.version }}
  - refresh: True
  - cache_valid_time: 300
{% endif %}
  - name: {{ formula.name }}
{%- endfor %}

{% endif %}

{%- for formula_name, formula in environment.get('formula', {}).iteritems() %}

{%- if formula.source == 'git' %}

{%- if master.base_environment == environment_name %}

salt_master_{{ environment_name }}_{{ formula_name }}_formula:
  git.latest:
  - name: {{ formula.address }}
  - target: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}
  {% if formula.get("revision", "").split("/")[0] == "refs" %}
  - rev: {{ formula.branch|default("master") }}
  {%- if grains['saltversion'] >= "2015.8.0" %}
  - branch: {{ formula.branch|default("master") }}
  {%- endif %}
  {% else %}
  - rev: {{ formula.revision|default(formula.branch) }}
  {%- if grains['saltversion'] >= "2015.8.0" %}
  - branch: {{ formula.branch|default(formula.revision) }}
  {%- endif %}
  {% endif %}
  - force_reset: {{ formula.force_reset|default(False) }}
  - require:
    - file: salt_env_{{ environment_name }}_dirs
    - pkg: git_packages

{%- if formula.get("revision", "").split("/")[0] == "refs" %}

salt_master_{{ environment_name }}_{{ formula_name }}_formula_refs_workaround_fetch:
  module.run:
  - name: git.fetch
  - cwd: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}
  - opts: {{ formula.address }} {{ formula.revision }}
  - require:
    - git: salt_master_{{ environment_name }}_{{ formula_name }}_formula

salt_master_{{ environment_name }}_{{ formula_name }}_formula_refs_workaround_reset:
  module.run:
  - name: git.reset
  - cwd: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}
  - opts: --hard FETCH_HEAD
  - require:
    - module: salt_master_{{ environment_name }}_{{ formula_name }}_formula_refs_workaround_fetch

salt_master_{{ environment_name }}_{{ formula_name }}_formula_refs_workaround_rebase:
  module.run:
  - name: git.rebase
  - cwd: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}
  - rev: origin/{{ formula.branch|default("master") }}
  - require:
    - module: salt_master_{{ environment_name }}_{{ formula_name }}_formula_refs_workaround_reset

{%- endif %}

salt_env_{{ environment_name }}_{{ formula_name }}_link:
  file.symlink:
  - name: /usr/share/salt-formulas/env/{{ formula_name }}
  - target: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}/{{ formula_name }}
  - require:
    - file: salt_env_{{ environment_name }}_dirs
  - force: True
  - makedirs: True

{%- for grain_name, grain in formula.get('grain', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ grain_name }}_grain:
  file.symlink:
  - name: /usr/share/salt-formulas/env/_grains/{{ grain_name }}
  - target: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}/_grains/{{ grain_name }}
  - force: True
  - makedirs: True

{%- endfor %}

{%- for module_name, module in formula.get('module', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ module_name }}_module:
  file.symlink:
  - name: /usr/share/salt-formulas/env/_modules/{{ module_name }}
  - target: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}/_modules/{{ module_name }}
  - force: True
  - makedirs: True

{%- endfor %}

{%- for state_name, state in formula.get('state', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ state_name }}_state:
  file.symlink:
  - name: /usr/share/salt-formulas/env/_states/{{ state_name }}
  - target: /usr/share/salt-formulas/env/_formulas/{{ formula_name }}/_states/{{ state_name }}
  - force: True
  - makedirs: True

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
  - force: True
  - makedirs: True

{%- for grain_name, grain in formula.get('grain', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ grain_name }}_grain:
  file.symlink:
  - name: /srv/salt/env/{{ environment_name }}/_grains/{{ grain_name }}
  - target: /srv/salt/env/{{ environment_name }}/_formulas/{{ formula_name }}/_grains/{{ grain_name }}
  - force: True
  - makedirs: True

{%- endfor %}

{%- for module_name, module in formula.get('module', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ module_name }}_module:
  file.symlink:
  - name: /srv/salt/env/{{ environment_name }}/_grains/{{ module_name }}
  - target: /srv/salt/env/{{ environment_name }}/_formulas/{{ formula_name }}/_grains/{{ module_name }}
  - force: True
  - makedirs: True

{%- endfor %}

{%- for state_name, state in formula.get('state', {}).iteritems() %}

salt_master_{{ environment_name }}_{{ state_name }}_state:
  file.symlink:
  - name: /srv/salt/env/{{ environment_name }}/_grains/{{ state_name }}
  - target: /srv/salt/env/{{ environment_name }}/_formulas/{{ formula_name }}/_grains/{{ state_name }}
  - force: True
  - makedirs: True

{%- endfor %}

{%- endif %}

{%- endif %}

{%- endfor %}

{%- endfor %}

{# end new #}

{%- endif %}

