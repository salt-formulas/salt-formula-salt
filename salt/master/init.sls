include:
- salt.master.service
- salt.master.env
- salt.master.pillar
- salt.master.minion
{%- if pillar.salt.master.windows_repo is defined %}
- salt.master.win_repo
{%- endif %}
{#
- salt.master.orchestrate
#}