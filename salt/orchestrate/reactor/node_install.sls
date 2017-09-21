{%- set node_name = salt['pillar.get']('event_originator') %}

linux_state:
  salt.state:
  - tgt: '{{ node_name }}'
  - sls: linux
  - queue: True

salt_state:
  salt.state:
  - tgt: '{{ node_name }}'
  - sls: salt.minion
  - queue: True
  - require:
    - salt: linux_state

misc_states:
  salt.state:
  - tgt: '{{ node_name }}'
  - sls: ntp,openssh
  - queue: True
  - require:
    - salt: salt_state

