salt:
  control:
    enabled: true
    cloud_enabled: true
    provider:
      digitalocean_account:
        engine: digital_ocean
        region: New York 1
        client_key: xxxxxxx
        api_key: xxxxxxx
    cluster:
      dc01_prd:
        domain: dc01.prd.domain.com
        engine: cloud
        config:
          engine: salt
          host: master.dc01.domain.com
        node:
          ubuntu1:
            provider: digitalocean_account
            image: Ubuntu14.04 x86_64
            size: m1.medium
          ubuntu2:
            provider: digitalocean_account
            image: Ubuntu14.04 x86_64
            size: m1.medium