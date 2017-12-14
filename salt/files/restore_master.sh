#!/bin/sh
{%- from "salt/map.jinja" import master with context %}

{%- if master.initial_data is defined %}
mkdir -p /etc/salt/pki.bak
mv /etc/salt/pki/* /etc/salt/pki.bak
scp -r backupninja@{{ master.initial_data.source }}:/srv/backupninja/{{ master.initial_data.host }}/etc/salt/pki/pki.0/* /etc/salt/pki
{%- if master.pillar.engine == 'reclass' or (master.pillar.engine == 'composite' and master.pillar.reclass is defined) %}
scp -r backupninja@{{ master.initial_data.source }}:/srv/backupninja/{{ master.initial_data.host }}/srv/salt/reclass/nodes/_generated/_generated.0/* /srv/salt/reclass/nodes/_generated
{%- endif %}
{%- endif %}
