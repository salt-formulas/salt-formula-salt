{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

include:
- salt.minion.service

{%- for ca_name,ca in minion.ca.iteritems() %}

/etc/pki/ca/{{ ca_name }}/certs:
  file.directory:
  - makedirs: true

/etc/pki/ca/{{ ca_name }}/ca.key:
  x509.private_key_managed:
  - bits: 4096
  - backup: True
  - require:
    - file: /etc/pki/ca/{{ ca_name }}/certs

/etc/pki/ca/{{ ca_name }}/ca.crt:
  x509.certificate_managed:
  - signing_private_key: /etc/pki/ca/{{ ca_name }}/ca.key
  - CN: "{{ ca.common_name }}"
  {%- if ca.country is defined %}
  - C: {{ ca.country }}
  {%- endif %}
  {%- if ca.state is defined %}
  - ST: {{ ca.state }}
  {%- endif %}
  {%- if ca.locality is defined %}
  - L: {{ ca.locality }}
  {%- endif %}
  {%- if ca.organization is defined %}
  - O: {{ ca.organization }}
  {%- endif %}
  {%- if ca.organization_unit is defined %}
  - OU: {{ ca.organization_unit }}
  {%- endif %}
  - basicConstraints: "critical,CA:TRUE"
  - keyUsage: "critical,cRLSign,keyCertSign"
  - subjectKeyIdentifier: hash
  - authorityKeyIdentifier: keyid,issuer:always
  - days_valid: {{ ca.days_valid.authority }}
  - days_remaining: 0
  - backup: True
  - require:
    - x509: /etc/pki/ca/{{ ca_name }}/ca.key

salt_system_ca_mine_send_ca_{{ ca_name }}:
  module.run:
  - name: mine.send
  - func: x509.get_pem_entries
  - kwargs:
      glob_path: /etc/pki/ca/{{ ca_name }}/ca.crt
  - require:
    - x509: /etc/pki/ca/{{ ca_name }}/ca.crt

{%- endfor %}

{%- endif %}
