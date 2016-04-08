{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

include:
- salt.minion.service

{%- for cert_name,cert in minion.cert.iteritems() %}

/etc/pki/cert/{{ cert.authority }}:
  file.directory:
  - makedirs: true

/etc/pki/cert/{{ cert.authority }}/{{ cert.common_name }}.key:
  x509.private_key_managed:
  - bits: 4096

/etc/pki/cert/{{ cert.authority }}/{{ cert.common_name }}.crt:
  x509.certificate_managed:
  - ca_server: wst01.newt.cz
  - signing_policy: {{ cert.authority }}
  - public_key: /etc/pki/cert/{{ cert.authority }}/{{ cert.common_name }}.key
  - CN: {{ cert.common_name }}
  - days_remaining: 30
  - backup: True

{%- endfor %}

{#
/usr/local/share/ca-certificates:
  file.directory: []

{%- for ca_path,ca in salt['mine.get']('ca', 'x509.get_pem_entries')['ca'].iteritems() %}

/usr/local/share/ca-certificates/{{ ca }}.crt:
  x509.pem_managed:
  - text: {{ salt['mine.get']('ca', 'x509.get_pem_entries')['ca']['/etc/pki/ca.crt']|replace('\n', '') }}

{%- endfor %}
#}

{%- endif %}