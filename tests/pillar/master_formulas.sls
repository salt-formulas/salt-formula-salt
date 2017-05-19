git:
  client:
    enabled: true
linux:
  system:
    enabled: true
salt:
  master:
    enabled: true
    pillar:
      source:
        engine: local
    environment:
      prd:
        formula:
          keepalived:
            source: pkg
            name: salt-formula-keepalived
          haproxy:
            source: pkg
            name: salt-formula-haproxy
          libvirt:
            source: pkg
            name: salt-formula-libvirt
            version: latest
          ntp:
            source: pkg
            name: salt-formula-ntp
            version: latest
          openssh:
            source: pkg
            name: salt-formula-openssh
            version: latest
          mysql:
            source: pkg
            name: salt-formula-mysql
            version: purged
          postgresql:
            source: pkg
            name: salt-formula-postgresql
            version: removed
      dev:
        formula:
          aptly:
            source: git
            address: 'https://github.com/salt-formulas/salt-formula-aptly.git'
            revision: master
          bind:
            source: git
            address: 'https://github.com/salt-formulas/salt-formula-bind.git'
            revision: master
