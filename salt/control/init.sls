{%- if pillar.salt.control is defined %}
include:
{%- if pillar.salt.control.cloud_enabled is defined %}
- salt.control.cloud
{%- endif %}
{%- if pillar.salt.control.docker_enabled is defined %}
- salt.control.docker
{%- endif %}
{%- if pillar.salt.control.maas_enabled is defined %}
- salt.control.maas
{%- endif %}
{%- if pillar.salt.control.virt_enabled is defined %}
- salt.control.virt
{%- endif %}
{%- endif %}
