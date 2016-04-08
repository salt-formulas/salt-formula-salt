{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

include:
- salt.minion.service

{%- for cert_name,cert in minion.cert.iteritems() %}
{%- set rowloop = loop %}

ca_dir_{{ cert.authority }}_{{ loop.index }}:
  file.directory:
  - name: /etc/pki/cert/{{ cert.authority }}
  - makedirs: true

/etc/pki/cert/{{ cert.authority }}/{{ cert.common_name }}.key:
  x509.private_key_managed:
  - bits: 4096

/etc/pki/cert/{{ cert.authority }}/{{ cert.common_name }}.crt:
  x509.certificate_managed:
  - ca_server: {{ cert.host }}
  - signing_policy: {{ cert.authority }}_{{ cert.signing_policy }}
  - public_key: /etc/pki/cert/{{ cert.authority }}/{{ cert.common_name }}.key
  - CN: {{ cert.common_name }}
  - days_remaining: 30
  - backup: True

{%- for ca_path,ca_cert in salt['mine.get'](cert.host, 'x509.get_pem_entries')[cert.host].iteritems() %}

{%- if '/etc/pki/ca/'+cert.authority in ca_path %}

ca_cert_{{ cert.authority }}_{{ rowloop.index }}:
  x509.pem_managed:
  - name: /etc/pki/cert/{{ cert.authority }}/ca.crt
  - text: {{ ca_cert|replace('\n', '') }}

{%- endif %}

{%- endfor %}

{%- endfor %}

{%- endif %}