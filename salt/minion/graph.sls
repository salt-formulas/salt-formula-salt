{%- from "salt/map.jinja" import minion with context %}
{%- if minion.enabled %}

salt_graph_packages:
  pkg.latest:
  - names: {{ minion.graph_pkgs }}
  - require:
    - {{ minion.install_state }}

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