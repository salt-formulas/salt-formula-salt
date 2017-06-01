include:
- salt.minion.service
- salt.minion.grains
{%- if pillar.salt.minion.graph_states is defined %}
- salt.minion.graph
{%- endif %}
{%- if pillar.salt.minion.ca is defined %}
- salt.minion.ca
{%- endif %}
- salt.minion.cert
{%- if pillar.salt.minion.proxy_minion is defined %}
- salt.minion.proxy
{%- endif %}
