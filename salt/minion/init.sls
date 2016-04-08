include:
- salt.minion.service
- salt.minion.grains
{%- if pillar.salt.minion.graph_states is defined %}
- salt.minion.graph
{%- endif %}
{%- if pillar.salt.minion.ca is defined %}
- salt.minion.ca
{%- endif %}
{%- if pillar.salt.minion.cert is defined %}
- salt.minion.cert
{%- endif %}