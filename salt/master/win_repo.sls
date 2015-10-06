{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

include:
- git.client
- salt.master.service

{%- if master.windows_repo is defined %}

/srv/salt/win:
  file.directory:
  - user: root
  - mode: 755
  - makedirs: true
  - require:
    - file: /srv/salt/env

{%- if master.windows_repo.source == 'git' %}

{{ master.windows_repo.address }}:
  git.latest:
  - target: /srv/salt/win/repo
  - rev: {{ master.windows_repo.branch }}
  - require:
    - file: /srv/salt/win
    - pkg: git_packages

salt_master_update_win_repo:
  cmd.run:
  - name: salt-run winrepo.genrepo
  - require:
    - git: {{ master.windows_repo.address }}

{%- for environment in master.environments %}

/srv/salt/env/{{ name }}/win:
  file.symlink:
  - target: /srv/salt/win
  - require:
    - file: /srv/salt/env/{{ name }}
    - git: {{ master.windows_repo.address }}

{%- endfor %}

{%- endif %}

{%- endif %}

{%- endif %}