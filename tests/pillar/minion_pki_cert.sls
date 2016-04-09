salt:
  minion:
    enabled: true
    cert:
      test_server:
        host: minion.with.ca
        signing_policy: cert_server
        authority: Company CA
        common_name: test.server.domain.tld
        alternative_names: DNS:www1.server.domain.tld,DNS:www2.server.domain.tld,IP:1.2.3.4,IP:2.3.4.5
      test_client:
        host: minion.with.ca
        signing_policy: cert_client
        authority: Company CA
        common_name: test.client.domain.tld
      test_edge_ca:
        host: minion.with.ca
        signing_policy: ca_edge
        authority: Company CA
        common_name: test.ca.domain.tld