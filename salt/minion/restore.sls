{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

{%- if minion.ca is defined %}

{%- if minion.initial_data is defined %}

/srv/salt/restore_minion.sh:
  file.managed:
  - source: salt://salt/files/restore_minion.sh
  - mode: 700
  - template: jinja

salt_minion_restore_state:
  cmd.run:
  - name: /srv/salt/restore_minion.sh
  - unless: "test -e /srv/salt/minion-restored"
  - cwd: /root
  - require:
    - file: /srv/salt/restore_minion.sh

salt_minion_restore_completed:
  file.managed:
  - name: /srv/salt/minion-restored
  - source: {}
  - require:
    - cmd: salt_minion_restore_state

{%- endif %}

{%- endif %}

{%- endif %}
