{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

salt_minion_packages:
  pkg.latest:
  - names: {{ minion.pkgs }}

salt_minion_grains_dir:
  file.directory:
  - name: /etc/salt/grains.d
  - mode: 700
  - makedirs: true
  - user: root

salt_minion_grains_file:
  cmd.run:
  - name: cat /etc/salt/grains.d/* > /etc/salt/grains
  - require:
    - file: salt_minion_grains_dir

/etc/salt/minion.d/minion.conf:
  file.managed:
  - source: salt://salt/files/minion.conf
  - user: root
  - group: root
  - template: jinja
  - require:
    - pkg: salt_minion_packages
    - file: salt_minion_grains_dir
  - watch_in:
    - service: salt_minion_service

salt_minion_service:
  service.running:
  - name: {{ minion.service }}
  - enable: true

{%- if minion.graph_states %}

salt_graph_packages:
  pkg.latest:
  - names: {{ minion.graph_pkgs }}
  - require:
    - pkg: salt_minion_packages

salt_graph_states_packages:
  pkg.latest:
  - names: {{ minion.graph_states_pkgs }}

/root/salt-state-graph.py:
  file.managed:
  - source: salt://salt/files/salt-state-graph.py
  - require:
    - pkg: salt_graph_packages

/root/salt-state-graph.sh:
  file.managed:
  - source: salt://salt/files/salt-state-graph.sh
  - require:
    - pkg: salt_graph_packages

{%- endif %}

{%- endif %}