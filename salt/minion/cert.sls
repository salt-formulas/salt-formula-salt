{%- from "salt/map.jinja" import minion with context %}

{%- if minion.enabled %}

{%- if grains.os_family == 'RedHat' %}
{%- set cacerts_dir='/etc/pki/ca-trust/source/anchors' %}
{%- else %}
{%- set cacerts_dir='/usr/local/share/ca-certificates' %}
{%- endif %}

{%- if minion.cert is defined %}

{%- set created_ca_files = [] %}

{%- for cert_name,cert in minion.get('cert', {}).iteritems() %}
{%- set rowloop = loop %}

{%- set key_file  = cert.get('key_file', '/etc/ssl/private/' + cert.common_name + '.key') %}
{%- set cert_file = cert.get('cert_file', '/etc/ssl/certs/' + cert.common_name + '.crt') %}
{%- set ca_file = cert.get('ca_file', '/etc/ssl/certs/ca-' + cert.authority + '.crt') %}
{%- set key_dir = salt['file.dirname'](key_file) %}
{%- set cert_dir = salt['file.dirname'](cert_file) %}
{%- set ca_dir = salt['file.dirname'](ca_file) %}

{# Only ensure directories exists, don't touch permissions, etc. #}
salt_minion_cert_{{ cert_name }}_dirs:
  file.directory:
    - names:
      - {{ key_dir }}
      - {{ cert_dir }}
      - {{ ca_dir }}
    - makedirs: true
    - replace: false

{{ key_file }}:
  x509.private_key_managed:
    - bits: {{ cert.get('bits', 4096) }}
    - require:
      - file: salt_minion_cert_{{ cert_name }}_dirs
    {%- if cert.all_file is defined %}
    - watch_in:
      - cmd: salt_minion_cert_{{ cert_name }}_all
    {%- endif %}

{{ key_file }}_key_permissions:
  file.managed:
    - name: {{ key_file }}
    - mode: {{ cert.get("mode", 0600) }}
    {%- if salt['user.info'](cert.get("user", "root")) %}
    - user: {{ cert.get("user", "root") }}
    {%- endif %}
    {%- if salt['group.info'](cert.get("group", "root")) %}
    - group: {{ cert.get("group", "root") }}
    {%- endif %}
    - replace: false
    - watch:
      - x509: {{ key_file }}

{{ cert_file }}:
  x509.certificate_managed:
    {% if cert.host is defined %}- ca_server: {{ cert.host }}{%- endif %}
    {% if cert.authority is defined and cert.signing_policy is defined %}
    - signing_policy: {{ cert.authority }}_{{ cert.signing_policy }}
    {%- endif %}
    - public_key: {{ key_file }}
    - CN: "{{ cert.common_name }}"
    {% if cert.state is defined %}- ST: {{ cert.state }}{%- endif %}
    {% if cert.country is defined %}- C: {{ cert.country }}{%- endif %}
    {% if cert.locality is defined %}- L: {{ cert.locality }}{%- endif %}
    {% if cert.organization is defined %}- O: {{ cert.organization }}{%- endif %}
    {% if cert.signing_private_key is defined and cert.signing_cert is defined %}
    - signing_private_key: "{{ cert.signing_private_key }}"
    - signing_cert: "{{ cert.signing_cert }}"
    {%- endif %}
    {% if cert.alternative_names is defined %}
    - subjectAltName: "{{ cert.alternative_names }}"
    {%- endif %}
    {%- if cert.extended_key_usage is defined %}
    - extendedKeyUsage: "{{ cert.extended_key_usage }}"
    {%- endif %}
    {%- if cert.key_usage is defined %}
    - keyUsage: "{{ cert.key_usage }}"
    {%- endif %}
    - days_remaining: 30
    - backup: True
    - watch:
      - x509: {{ key_file }}
    {%- if cert.all_file is defined %}
    - watch_in:
      - cmd: salt_minion_cert_{{ cert_name }}_all
    {%- endif %}

{{ cert_file }}_cert_permissions:
  file.managed:
    - name: {{ cert_file }}
    - mode: {{ cert.get("mode", 0600) }}
    {%- if salt['user.info'](cert.get("user", "root")) %}
    - user: {{ cert.get("user", "root") }}
    {%- endif %}
    {%- if salt['group.info'](cert.get("group", "root")) %}
    - group: {{ cert.get("group", "root") }}
    {%- endif %}
    - replace: false
    - watch:
      - x509: {{ cert_file }}

{%- if cert.host is defined and ca_file not in created_ca_files %}
{%- for ca_path,ca_cert in salt['mine.get'](cert.host, 'x509.get_pem_entries').get(cert.host, {}).iteritems() %}

{%- if '/etc/pki/ca/'+cert.authority in ca_path %}

{{ ca_file }}:
  x509.pem_managed:
    - name: {{ ca_file }}
    - text: {{ ca_cert|replace('\n', '') }}
    - watch:
      - x509: {{ cert_file }}
    {%- if cert.all_file is defined %}
    - watch_in:
      - cmd: salt_minion_cert_{{ cert_name }}_all
    {%- endif %}


{{ ca_file }}_cert_permissions:
  file.managed:
    - name: {{ ca_file }}
    - mode: 0644
    - watch:
      - x509: {{ ca_file }}

{%- endif %}

{%- endfor %}
{%- do created_ca_files.append(ca_file) %}
{%- endif %}

{%- if cert.all_file is defined %}

salt_minion_cert_{{ cert_name }}_all:
  cmd.wait:
    - name: cat {{ key_file }} {{ cert_file }} {{ ca_file }} > {{ cert.all_file }}

{{ cert.all_file }}_cert_permissions:
  file.managed:
    - name: {{ cert.all_file }}
    - mode: {{ cert.get("mode", 0600) }}
    {%- if salt['user.info'](cert.get("user", "root")) %}
    - user: {{ cert.get("user", "root") }}
    {%- endif %}
    {%- if salt['group.info'](cert.get("group", "root")) %}
    - group: {{ cert.get("group", "root") }}
    {%- endif %}
    - replace: false
    - watch:
      - cmd: salt_minion_cert_{{ cert_name }}_all
{%- endif %}

{%- endfor %}

{%- endif %}

salt_ca_certificates_packages:
  pkg.installed:
{%- if grains.os_family == 'Debian' %}
    - name: ca-certificates
{%- elif grains.os_family == 'RedHat' %}
    - name: ca-certificates
{%- else %}
    - name: []
{%- endif %}

salt_update_certificates:
  cmd.wait:
{%- if grains.os_family == 'Debian' %}
    - name: "update-ca-certificates{% if minion.get('ca_certificates_cleanup') %} --fresh {% endif %}"
{%- elif grains.os_family == 'RedHat' %}
    - name: "update-ca-trust extract"
{%- else %}
    - name: true
{%- endif %}
    - require:
      - pkg: salt_ca_certificates_packages

{%- if minion.get('trust_salt_ca', True) %}

{%- for trusted_ca_minion in minion.get('trusted_ca_minions', []) %}
{%- for ca_host, certs in salt['mine.get'](trusted_ca_minion+'*', 'x509.get_pem_entries').iteritems() %}
{%- for ca_path, ca_cert in certs.iteritems() %}
{%- if ca_path.startswith('/etc/pki/ca/') and ca_path.endswith('ca.crt') %}

{# authority name can be obtained only from a cacert path in case of mine.get #}
{%- set ca_authority = ca_path.split("/")[4] %}
{%- set cacert_file="%s/ca-%s.crt" % (cacerts_dir,ca_authority) %}

salt_trust_ca_{{ cacert_file }}:
  x509.pem_managed:
    - name: {{ cacert_file }}
    - text: {{ ca_cert|replace('\n', '') }}
    - makedirs: True
    - watch_in:
      - file: salt_trust_ca_{{ cacert_file }}_permissions
      - cmd: salt_update_certificates

salt_trust_ca_{{ cacert_file }}_permissions:
  file.managed:
    - name: {{ cacert_file }}
    - mode: 0444

{%- endif %}
{%- endfor %}
{%- endfor %}
{%- endfor %}
{%- endif %}

{%- endif %}
