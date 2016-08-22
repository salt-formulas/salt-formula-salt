include:
- salt.master.service
- salt.master.env
- salt.master.pillar
- salt.master.minion
{%- if pillar.salt.master.windows_repo is defined %}
- salt.master.win_repo
{%- endif %}
{%- if pillar.salt.master.ssh is defined %}
- salt.master.ssh
{%- endif %}
{#
- salt.master.orchestrate
#}
