salt:
  minion:
    enabled: true
    cert:
      test_service:
        host: minion.with.ca
        authority: Company CA
        common_name: test.service.domain.tld
