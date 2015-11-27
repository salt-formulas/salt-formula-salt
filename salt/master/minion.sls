{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

include:
- salt.master.service

{%- if master.minion is defined %}

/srv/salt/minion_keys:
  file.directory:
  - makedirs: true
  - require:
    - pkg: salt_master_packages

{%- for name, environment in master.environment.iteritems() %}

/srv/salt/env/{{ name }}/minion_keys:
  file.symlink:
  - target: /srv/salt/minion_keys
  - require:
    - file: /srv/salt/minion_keys

{%- endfor %}

{%- for minion in master.minion %}

generate_key_{{ minion.name }}:
  cmd.run:
  - name: salt-key --gen-keys={{ minion.name }} --gen-keys-dir=/srv/salt/minion_keys
  - unless: "test -e /srv/salt/minion_keys/{{ minion.name}}.pem"
  - require:
    - file: /srv/salt/minion_keys

copy_generated_key_{{ minion.name }}:
  cmd.run:
  - name: cp /srv/salt/minion_keys/{{ minion.name }}.pub /etc/salt/pki/master/minions/{{ minion.name }}
  - unless: "test -e /etc/salt/pki/master/minions/{{ minion.name }}"
  - require:
    - cmd: generate_key_{{ minion.name }}

{%- endfor %}

{%- endif %}

{%- endif %}
