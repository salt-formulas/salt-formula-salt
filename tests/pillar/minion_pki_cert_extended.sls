salt:
  #master:
  # enabled: true
  # accept_policy:
  #   open_mode
  # peer:
  #   .*:
  #     - x509.sign_remote_certificate
  minion:
    enabled: true
    cert:
      ceph_cert:
          all_file:
              /srv/salt/pki/ci/ceph-with-key.ci.local.pem
          alternative_names:
              IP:127.0.0.1,DNS:salt.ci.local,DNS:ceph.ci.local,DNS:radosgw.ci.local,DNS:swift.ci.local
          cert_file:
              /srv/salt/pki/ci/ceph.ci.local.crt
          common_name:
              ceph_mon.ci.local
          key_file:
              /srv/salt/pki/ci/ceph.ci.local.key
          authority:
              salt-ca-test
          host:
              salt.ci.local
          signing_policy:
              cert_server
      proxy_cert:
          all_file:
              /srv/salt/pki/ci/prx-with-key.ci.local.pem
          alternative_names:
              IP:127.0.0.1,DNS:salt.ci.local,DNS:proxy.ci.local
          cert_file:
              /srv/salt/pki/ci/prx.ci.local.crt
          common_name:
              prx.ci.local
          key_file:
              /srv/salt/pki/ci/prx.ci.local.key
          authority:
             salt-ca-default
          host:
             salt.ci.local
          signing_policy:
             cert_server
