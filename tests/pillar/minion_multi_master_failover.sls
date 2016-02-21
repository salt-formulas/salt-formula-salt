salt:
  minion:
    enabled: true
    masters:
    - host: config01.dc01.domain.com
    - host: config02.dc01.domain.com
    master_type: failover
