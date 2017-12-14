{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

{%- if master.initial_data is defined %}

/srv/salt/restore_master.sh:
  file.managed:
  - source: salt://salt/files/restore_master.sh
  - mode: 700
  - template: jinja

salt_master_restore_state:
  cmd.run:
  - name: /srv/salt/restore_master.sh
  - unless: "test -e /srv/salt/master-restored"
  - cwd: /root
  - require:
    - file: /srv/salt/restore_master.sh

salt_master_restore_completed:
  file.managed:
  - name: /srv/salt/master-restored
  - source: {}
  - require:
    - cmd: salt_master_restore_state

{%- endif %}

{%- endif %}
