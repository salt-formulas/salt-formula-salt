
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
    - require:
      - salt: salt_state_config_node

