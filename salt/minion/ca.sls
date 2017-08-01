{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

include:
- salt.minion.service

{%- for ca_name,ca in minion.ca.iteritems() %}

{%- set ca_file = ca.get('ca_file', '/etc/pki/ca/' ~ ca_name ~ '/ca.crt') %}
{%- set ca_key_file = ca.get('ca_key_file', '/etc/pki/ca/' ~ ca_name ~ '/ca.key') %}
{%- set ca_key_usage = ca.get('key_usage',"critical,cRLSign,keyCertSign") %}

{%- set ca_dir = salt['file.dirname'](ca_file) %}
{%- set ca_key_dir = salt['file.dirname'](ca_key_file) %}
{%- set ca_certs_dir = ca_dir ~ '/certs' %}

salt_minion_cert_{{ ca_name }}_dirs:
  file.directory:
    - names:
      - {{ ca_dir }}
      - {{ ca_key_dir }}
      - {{ ca_certs_dir }}
    - makedirs: true

{{ ca_key_file }}:
  x509.private_key_managed:
  - bits: 4096
  - backup: True
  - require:
    - file: {{ ca_certs_dir }}

# TODO: Squash this with the previous state after switch to Salt version >= 2016.11.2
{{ ca_name }}_key_permissions:
  file.managed:
    - name: {{ ca_key_file }}
    - mode: {{ ca.get("mode", 0600) }}
    {%- if salt['user.info'](ca.get("user", "root")) %}
    - user: {{ ca.get("user", "root") }}
    {%- endif %}
    {%- if salt['group.info'](ca.get("group", "root")) %}
    - group: {{ ca.get("group", "root") }}
    {%- endif %}
    - replace: false
    - require:
      - x509: {{ ca_key_file }}

{{ ca_file }}:
  x509.certificate_managed:
  - signing_private_key: {{ ca_key_file }}
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
  - keyUsage: {{ ca_key_usage }}
  - subjectKeyIdentifier: hash
  - authorityKeyIdentifier: keyid,issuer:always
  - days_valid: {{ ca.days_valid.authority }}
  - days_remaining: 0
  - backup: True
  - require:
    - x509: {{ ca_key_file }}

# TODO: Squash this with the previous state after switch to Salt version >= 2016.11.2
{{ ca_name }}_cert_permissions:
  file.managed:
    - name: {{ ca_file }}
    - mode: 0644
    {%- if salt['user.info'](ca.get("user", "root")) %}
    - user: {{ ca.get("user", "root") }}
    {%- endif %}
    {%- if salt['group.info'](ca.get("group", "root")) %}
    - group: {{ ca.get("group", "root") }}
    {%- endif %}
    - require:
      - x509: {{ ca_file }}

salt_system_ca_mine_send_ca_{{ ca_name }}:
  module.run:
  - name: mine.send
  - func: x509.get_pem_entries
  - kwargs:
      glob_path: {{ ca_file }}
  - require:
    - x509: {{ ca_file }}

{%- endfor %}

{%- endif %}
