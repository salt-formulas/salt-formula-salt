salt:
  minion:
    enabled: true
    master:
      host: config01.dc01.domain.com
    log:
      level: info
      file: '/var/log/salt/minion'
      level_logfile: warning
