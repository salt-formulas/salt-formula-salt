{%- from "salt/map.jinja" import master with context %}
{%- if master.enabled %}

{%- if pillar.django_pki is defined %}
{%- if pillar.django_pki.server.enabled %}

include:
- salt.master.service

{#
{%- for environment_name, environment in master.environment.iteritems() %}

/srv/salt/env/{{ environment_name }}/pki:
  file.symlink:
  - target: /srv/django_pki/site/pki

{%- endfor %}
#}

{%- endif %}
{%- endif %}

{%- endif %}