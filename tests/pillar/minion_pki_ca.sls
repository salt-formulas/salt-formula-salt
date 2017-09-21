salt:
  minion:
    enabled: true
    ca:
      salt-ca-default:
        common_name: Test CA Default
        country: Czech
        state: Prague
        locality: Zizkov
        days_valid:
          authority: 3650
          certificate: 90
        signing_policy:
          cert_server:
            type: v3_edge_cert_server
            minions: '*'
          cert_client:
            type: v3_edge_cert_client
            minions: '*'
          ca_edge:
            type: v3_edge_ca
            minions: '*'
          ca_intermediate:
            type: v3_intermediate_ca
            minions: '*'
      salt-ca-test:
        common_name: Test CA Testing
        country: Czech
        state: Prague
        locality: Karlin
        days_valid:
          authority: 3650
          certificate: 90
        signing_policy:
          cert_server:
            type: v3_edge_cert_server
            minions: '*'
          cert_client:
            type: v3_edge_cert_client
            minions: '*'
          ca_edge:
            type: v3_edge_ca
            minions: '*'
          ca_intermediate:
            type: v3_intermediate_ca
            minions: '*'
      salt-ca-alt:
        common_name: Alt CA Testing
        country: Czech
        state: Prague
        locality: Cesky Krumlov
        days_valid:
          authority: 3650
          certificate: 90
        signing_policy:
          cert_server:
            type: v3_edge_cert_server
            minions: '*'
          cert_client:
            type: v3_edge_cert_client
            minions: '*'
          ca_edge:
            type: v3_edge_ca
            minions: '*'
          ca_intermediate:
            type: v3_intermediate_ca
            minions: '*'
        ca_file: '/etc/test/ca.crt'
        ca_key_file: '/etc/test/ca.key'
        user: test
        group: test
