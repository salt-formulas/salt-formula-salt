_param:
  private-ipv4: &private-ipv4
  - id: private-ipv4
    type: ipv4
    link: ens2
    netmask: 255.255.255.0
    routes:
    - gateway: 192.168.0.1
      netmask: 0.0.0.0
      network: 0.0.0.0
virt:
  disk:
    three_disks:
      - system:
          size: 4096
          image: ubuntu.qcow
      - repository_snapshot:
          size: 8192
          image: snapshot.qcow
      - cinder-volume:
          size: 2048
  nic:
    control:
    - name: nic01
      bridge: br-pxe
      model: virtio
    - name: nic02
      bridge: br-cp
      model: virtio
    - name: nic03
      bridge: br-store-front
      model: virtio
    - name: nic04
      bridge: br-public
      model: virtio
    - name: nic05
      bridge: br-prv
      model: virtio
      virtualport:
        type: openvswitch
salt:
  minion:
    enabled: true
    master:
      host: config01.dc01.domain.com
  control:
    enabled: true
    virt_enabled: true
    size:
      small:
        cpu: 1
        ram: 1
      medium:
        cpu: 2
        ram: 4
      large:
        cpu: 4
        ram: 8
      medium_three_disks:
        cpu: 2
        ram: 4
        disk_profile: three_disks
    cluster:
      vpc20_infra:
        domain: neco.virt.domain.com
        engine: virt
        config:
          engine: salt
          host: master.domain.com
        cloud_init:
          user_data:
            disable_ec2_metadata: true
            resize_rootfs: True
            timezone: UTC
            ssh_deletekeys: True
            ssh_genkeytypes: ['rsa', 'dsa', 'ecdsa']
            ssh_svcname: ssh
            locale: en_US.UTF-8
            disable_root: true
            apt_preserve_sources_list: false
            apt:
              sources_list: ""
              sources:
                ubuntu.list:
                  source: ${linux:system:repo:ubuntu:source}
                mcp_saltstack.list:
                  source: ${linux:system:repo:mcp_saltstack:source}
          network_data:
            links:
            - id: ens2
              type: phy
              name: ens2
        node:
          ubuntu1:
            provider: node01.domain.com
            image: ubuntu.qcow
            size: medium
            img_dest: /var/lib/libvirt/ssdimages
          ubuntu2:
            provider: node02.domain.com
            image: bubuntu.qcomw
            size: small
            img_dest: /var/lib/libvirt/hddimages
          ubuntu3:
            provider: node03.domain.com
            image: meowbuntu.qcom2
            size: medium_three_disks
            cloud_init:
              network_data:
                networks:
                - <<: *private-ipv4
                  ip_address: 192.168.0.161
            rng:
              backend: /dev/urandom
              model: random
              rate:
                period: '1800'
                bytes: '1500'
