{% from "salt/map.jinja" import control with context %}
{%- if control.enabled %}

/srv/salt/cloud/maps:
  file.directory:
  - makedirs: true

/srv/salt/cloud/userdata:
  file.directory:
  - makedirs: true

{%- for cluster_name, cluster in control.cluster.iteritems() %}

/srv/salt/cloud/maps/{{ cluster_name }}:
  file.managed:
  - source: salt://salt/files/map
  - user: root
  - group: root
  - template: jinja
  - require:
    - file: /srv/salt/cloud/maps
  - defaults:
      cluster_name: "{{ cluster_name }}"

/srv/salt/cloud/userdata/{{ cluster_name }}:
  file.directory:
  - makedirs: true

{%- for node_name, node in cluster.node.iteritems() %}

/srv/salt/cloud/userdata/{{cluster_name }}/{{ node_name }}.conf:
  file.managed:
  - source: salt://salt/files/userdata
  - user: root
  - group: root
  - template: jinja
  - require:
    - file: /srv/salt/cloud/userdata/{{ cluster_name }}
  - defaults:
      cluster_name: "{{ cluster_name }}"
      node_name: "{{ node_name }}"

{%- endfor %}

{%- endfor %}

{%- endif %}