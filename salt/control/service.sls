{% from "salt/map.jinja" import control with context %}
{%- if control.enabled %}

{%- if control.pkgs is defined and control.pkgs|length > 0 %}

salt_control_packages:
  pkg.installed:
    - names: {{ control.pkgs }}

{%- else %}
{# No system packages defined, install with pip #}

salt_control_packages:
  pkg.installed:
  - name: python-pip

{%- for package in control.python_pkgs %}
{{ package }}:
  pip.installed:
  - require:
    - pkg: salt_control_packages
{%- endfor %}

{%- endif %}

{%- endif %}
