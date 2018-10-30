{%- from "salt/map.jinja" import minion,env_vars with context %}

{%- if env_vars.engine is defined %}
  {%- if env_vars.engine == 'file' %}
/etc/default/salt-minion:
  file.managed:
  - source: salt://salt/files/etc_default_salt-minion
  - user: root
  - group: root
  - template: jinja
  - require:
    - {{ minion.install_state }}
  - onchanges_in:
    - cmd: salt_minion_service_restart

    {%- if grains.get('init', None) == 'systemd' %}
/etc/systemd/system/salt-minion.service.d/40-override:
  file.managed:
  - name: /etc/systemd/system/salt-minion.service.d/40-override
  - source: salt://salt/files/systemd/salt-minion.service_40-override
  - user: root
  - makedirs: True
  - group: root
  - template: jinja
  - require:
    - {{ minion.install_state }}
  - onchanges_in:
    - cmd: salt_minion_service_restart
    {%- endif %}
  {%- endif %}
{%- endif %}
