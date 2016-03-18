salt:
  minion:
    enabled: true
  control:
    enabled: true
    virt_enabled: true
    size:
      small:
        cpu: 1
        ram: 1
        hdd: 10
      medium:
        cpu: 2
        ram: 4
        hdd: 20
      large:
        cpu: 4
        ram: 8
        hdd: 70
    cluster:
      vpc20_infra:
        domain: neco.virt.domain.com
        engine: virt
        config:
          engine: salt
          host: master.domain.com
        node:
          ubuntu1:
            provider: node01.domain.com
            image: "salt://ubuntu.qcow"
            size: medium
          ubuntu2:
            provider: node02.domain.com
            image: "http://ubuntu.com"
            size: small
