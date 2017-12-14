salt:
  minion:
    enabled: true
    backup: true
    initial_data:
      engine: backupninja
      source: backup-node-host
      host: original-salt-master-id
