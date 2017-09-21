{%- from "salt/map.jinja" import proxy_minion with context %}

{%- set napalm = false %}

{%- for proxy_name, proxy_device in proxy_minion.get('device', {}).iteritems() %}

{%- if proxy_device.engine == 'napalm' %}

{%- set napalm = true %}

{%- endif %}

{%- endfor %}

/etc/systemd/system/salt-proxy@.service:
  file.managed:
  - source: salt://salt/files/salt-proxy.service
  - template: jinja

/etc/salt/proxy:
  file.managed:
  - source: salt://salt/files/proxy.conf
  - template: jinja
  - defaults:
      napalm: {{ napalm }}
      proxy_minion: {{ proxy_minion|yaml }}

{%- if napalm %}

network_proxy_packages:
  pkg.installed:
  - names: {{ proxy_minion.napalm_pkgs }}

napalm:
  pip.installed:
    - name: {{ proxy_minion.napalm_pip_pkgs}}
    - require:
      - pkg: python-pip

{%- endif %}

{%- for proxy_name, proxy_device in proxy_minion.get('device', {}).iteritems() %}

salt_proxy_{{ proxy_name }}_service:
  service.running:
  - enable: true
  - name: salt-proxy@{{ proxy_name }}
  - watch:
    - file: /etc/salt/proxy
    - file: /etc/systemd/system/salt-proxy@.service

{%- endfor %}
