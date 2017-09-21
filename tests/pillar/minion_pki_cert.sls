salt:
  #master:
  # enabled: true
  # accept_policy:
  #   open_mode
  # peer:
  #   '.*':
  #     - x509.sign_remote_certificate
  minion:
    enabled: true
    trusted_ca_minions:
     - cfg01
    cert:
      ceph_cert:
          alternative_names:
              IP:127.0.0.1,DNS:salt.ci.local,DNS:ceph.ci.local,DNS:radosgw.ci.local,DNS:swift.ci.local
          cert_file:
              /srv/salt/pki/ci/ceph.ci.local.crt
          common_name:
              ceph_mon.ci.local
          key_file:
              /srv/salt/pki/ci/ceph.ci.local.key
          country: CZ
          state: Prague
          locality: Karlin
          signing_cert:
              /etc/pki/ca/salt-ca-test/ca.crt
          signing_private_key:
              /etc/pki/ca/salt-ca-test/ca.key
          # Kitchen-Salt CI trigger `salt-call --local`, below attributes
          # can't be used as there is no required SaltMaster connectivity
          authority:
              salt-ca-test
          #host:
          #    salt.ci.local
          #signing_policy:
          #    cert_server
      proxy_cert:
          alternative_names:
              IP:127.0.0.1,DNS:salt.ci.local,DNS:proxy.ci.local
          cert_file:
              /srv/salt/pki/ci/prx.ci.local.crt
          common_name:
              prx.ci.local
          key_file:
              /srv/salt/pki/ci/prx.ci.local.key
          country: CZ
          state: Prague
          locality: Zizkov
          signing_cert:
              /etc/pki/ca/salt-ca-default/ca.crt
          signing_private_key:
              /etc/pki/ca/salt-ca-default/ca.key
          # Kitchen-Salt CI trigger `salt-call --local`, below attributes
          # can't be used as there is no required SaltMaster connectivity
          authority:
             salt-ca-default
          #host:
          #   salt.ci.local
          #signing_policy:
          #   cert_server
      test_cert:
          alternative_names:
              IP:127.0.0.1,DNS:salt.ci.local,DNS:test.ci.local
          cert_file:
              /srv/salt/pki/ci/test.ci.local.crt
          common_name:
              test.ci.local
          key_file:
              /srv/salt/pki/ci/test.ci.local.key
          country: CZ
          state: Prague
          locality: Cesky Krumlov
          signing_cert:
              /etc/test/ca.crt
          signing_private_key:
              /etc/test/ca.key
          # Kitchen-Salt CI trigger `salt-call --local`, below attributes
          # can't be used as there is no required SaltMaster connectivity
          authority:
             salt-ca-alt
