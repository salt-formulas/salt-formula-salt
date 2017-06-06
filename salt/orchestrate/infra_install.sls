
salt_state_config_node:
  salt.state:
    - tgt: 'salt:master'
    - tgt_type: pillar
    - sls: salt.master
    - queue: True

reclass_state_config_nodes
  salt.state:
    - tgt: 'reclass:storage'
    - tgt_type: pillar
    - sls: reclass
    - queue: True
    - requires:
      - salt: salt_state_config_node

linux_state_all_nodes:
  salt.state:
    - tgt: 'linux:system'
    - tgt_type: pillar
    - sls: linux
    - queue: True
    - requires:
      - salt: reclass_state_config_nodes

salt_state_all_nodes:
  salt.state:
    - tgt: 'salt:minion'
    - tgt_type: pillar
    - sls: salt.minion
    - queue: True
    - requires:
      - salt: linux_state_all_nodes

ntp_ssh_state_all_nodes:
  salt.state:
    - tgt: 'salt:minion'
    - tgt_type: pillar
    - sls: ntp,openssh
    - queue: True
    - requires:
      - salt: salt_state_all_nodes
