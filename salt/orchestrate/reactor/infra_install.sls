
linux_state_all_nodes:
  salt.state:
    - tgt: 'linux:system'
    - tgt_type: pillar
    - sls: linux
    - queue: True

salt_state_all_nodes:
  salt.state:
    - tgt: 'salt:minion'
    - tgt_type: pillar
    - sls: salt.minion
    - queue: True
    - require:
      - salt: linux_state_all_nodes

openssh_state_all_nodes:
  salt.state:
    - tgt: 'openssh:server'
    - tgt_type: pillar
    - sls: openssh
    - queue: True
    - require:
      - salt: salt_state_all_nodes

ntp_state_all_nodes:
  salt.state:
    - tgt: 'ntp:client'
    - tgt_type: pillar
    - sls: ntp
    - queue: True
    - require:
      - salt: salt_state_all_nodes
