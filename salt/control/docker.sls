{% from "salt/map.jinja" import control with context %}
{%- if control.enabled and control.docker_enabled is defined %}

{# TODO: dockerng implementation #}

{%- endif %}
