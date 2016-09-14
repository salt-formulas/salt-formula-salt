{%- if pillar.salt is defined %}
include:
{%- if pillar.salt.master is defined %}
- salt.master
{%- endif %}
{%- if pillar.salt.minion is defined %}
- salt.minion
{%- endif %}
{%- if pillar.salt.syndic is defined %}
- salt.syndic
{%- endif %}
{%- if pillar.salt.control is defined %}
- salt.control
{%- endif %}
{%- if pillar.salt.api is defined %}
- salt.api
{%- endif %}
{%- endif %}
