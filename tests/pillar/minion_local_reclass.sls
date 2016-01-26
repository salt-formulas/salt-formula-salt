salt:
  minion:
    enabled: true
    local: true
    pillar:
      engine: reclass
      data_dir: /srv/salt/reclass
git:
  client:
    enabled: true
linux:
  system:
    enabled: true
reclass:
  storage:
    enabled: true
    data_source:
      engine: git
      address:  'git@git.domain.com'
      branch: master