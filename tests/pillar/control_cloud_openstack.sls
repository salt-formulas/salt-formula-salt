salt:
  control:
    enabled: true
    cloud_enabled: true
    provider:
      openstack_account:
        engine: openstack
        insecure: true
        region: RegionOne
        identity_url: 'https://10.0.0.2:35357'
        tenant: project 
        user: user
        password: 'password'
        fixed_networks:
        - 123d3332-18be-4d1d-8d4d-5f5a54456554e
        floating_networks:
        - public
        ignore_cidr: 192.168.0.0/16
    cluster:
      dc01_prd:
        domain: dc01.prd.domain.com
        engine: cloud
        config:
          engine: salt
          host: master.dc01.domain.com
        node:
          ubuntu1:
            provider: openstack_account
            image: Ubuntu14.04 x86_64
            size: m1.medium
          ubuntu2:
            provider: openstack_account
            image: Ubuntu14.04 x86_64
            size: m1.medium