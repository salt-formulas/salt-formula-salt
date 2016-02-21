salt:
  minion:
    enabled: true
    local: true
    pillar:
      engine: salt
      source:
        engine: git
        address: 'git@repo.domain.com:salt/pillar-demo.git'
        branch: 'master'
