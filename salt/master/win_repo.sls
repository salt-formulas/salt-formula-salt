{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

include:
- git.client
- salt.master.service

/srv/salt/win:
  file.directory:
  - user: root
  - mode: 755
  - makedirs: true

{%- if master.win_repo.source == 'git' %}

{{ master.win_repo.address }}:
  git.latest:
  - target: /srv/salt/win/repo
  - rev: {{ master.win_repo.branch }}
  - require:
    - file: /srv/salt/win
    - pkg: git_packages

salt_master_update_win_repo:
  cmd.wait:
  - name: salt-run winrepo.genrepo
  - watch:
    - git: {{ master.win_repo.address }}

{%- endif %}

{%- endif %}
