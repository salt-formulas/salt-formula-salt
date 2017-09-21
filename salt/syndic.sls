{%- from "salt/map.jinja" import master, syndic with context %}
{%- if syndic.enabled %}

include:
- salt.master.service

salt_syndic_packages:
  pkg.installed:
  - names: {{ syndic.pkgs }}

/etc/salt/master.d/_syndic.conf:
  file.managed:
  - source: salt://salt/files/_syndic.conf
  - user: root
  - template: jinja
  - watch_in:
    - service: salt_master_service
    - service: salt_syndic_service

salt_syndic_service:
  service.running:
  - name: {{ syndic.service }}
  - enable: true

{%- if master.minion_data_cache == 'localfs' %}

{%- for master in syndic.get('masters', []) %}

salt_syndic_master_{{ master }}_fingerprint:
  ssh_known_hosts.present:
    - name: {{ master.host }}
    - user: root

salt_syndic_master_{{ master }}_sync_cache:
  rsync.synchronized:
    - name: {{ master.host }}:/var/cache/salt/master/minions
    - source: /var/cache/salt/master/minions/
    - prepare: True
    - update: True

salt_syndic_master_{{ master }}_sync_keys:
  rsync.synchronized:
    - name: {{ master.host }}:/etc/salt/pki/master/minions
    - source: /etc/salt/pki/master/minions/
    - prepare: True
    - update: True

{%- else %}

salt_syndic_master_fingerprint:
  ssh_known_hosts.present:
    - name: {{ syndic.master.host }}
    - user: root

salt_syndic_master_sync_cache:
  rsync.synchronized:
    - name: {{ syndic.master.host }}:/var/cache/salt/master/minions
    - source: /var/cache/salt/master/minions/
    - prepare: True
    - update: True

salt_syndic_master_sync_keys:
  rsync.synchronized:
    - name: {{ syndic.master.host }}:/etc/salt/pki/master/minions
    - source: /etc/salt/pki/master/minions/
    - prepare: True
    - update: True

{%- endfor %}

{%- endif %}

{%- endif %}

