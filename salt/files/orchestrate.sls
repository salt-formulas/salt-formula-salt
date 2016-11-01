{%- from "salt/map.jinja" import master with context %}

{%- if master.enabled %}
  {%- for environment_name, environment in master.get('environment', {}).iteritems() %}
    {%- if master.base_environment == environment_name %}
      {%- set sorted_priorities = priorities|dictsort(false, 'value') %}
      {#- Set debug = True to log simple state result - Fail/True - to /var/log/salt/ on both master and respective minions #}
      {%- set debug = False %}
      {#- Uncomment to print parsed metadata from formula_name/meta/salt.yml to output file %}

PARSED METADATA: 

---------------

Passed from salt/master/orchestrate.sls
---

priorities: {{ priorities }}

sorted_priorities: {{ sorted_priorities }}

args: {{ args }}

---------------

      #}

      {%- for state in sorted_priorities %}
        {%- set formula = state.0.split('.') %}

        {%- if salt['file.directory_exists']('/srv/salt/env/'+environment_name+'/'+formula.0+'/orchestrate') and formula|length > 1 and salt['file.file_exists']('/srv/salt/env/'+environment_name+'/'+formula.0+'/orchestrate/'+formula.1+'.sls') %}

{{ salt['cmd.run']('cat /srv/salt/env/'+environment_name+'/'+formula.0+'/orchestrate/'+formula.1+'.sls') }}

        {%- else %}
          {%- if args[ state.0 ] is defined %}

{{ state.0 }}:
  salt.state:
    - tgt: '{{ state.0|replace(".", ":") }}'
    - tgt_type: pillar
    - queue: True
    - sls: {{ state.0 }}
    {{ args[ state.0 ]|yaml(false)|indent(4) }}

            {%- if debug %}

{{ state.0 }}.logok:
  salt.function:
    - tgt: 'I@salt:master or I@{{ state.0|replace(".", ":") }}'
    - tgt_type: compound
    - queue: True
    - name: cmd.run
    - arg:
      - 'echo "$(date +"%d %h %Y %H:%M:%S") | state: {{ state.0}} - status: OK" >> /var/log/salt/orchestrate_runner'
    - require:
      - salt: {{ state.0 }}

{{ state.0 }}.logfail:
  salt.function:
    - tgt: 'I@salt:master or I@{{ state.0|replace(".", ":") }}'
    - tgt_type: compound
    - queue: True
    - name: cmd.run
    - arg:
      - 'echo "$(date +"%d %h %Y %H:%M:%S") | state: {{ state.0}} - status: FAIL" >> /var/log/salt/orchestrate_runner'
    - onfail:
      - salt: {{ state.0 }}

            {%- endif %}
          {%- else %}

{{ state.0 }}:
  salt.state:
    - tgt: '{{ state.0|replace(".", ":") }}{%- if "." not in state.0 %}:*{%- endif %}'
    - tgt_type: pillar
    - queue: True
    - sls: {{ state.0 }}

            {%- if debug %}

{{ state.0 }}.logok:
  salt.function:
    - tgt: 'I@salt:master or I@{{ state.0|replace(".", ":") }}'
    - tgt_type: compound
    - queue: True
    - name: cmd.run
    - arg:
      - 'echo "$(date +"%d %h %Y %H:%M:%S") | state: {{ state.0}} - status: OK" >> /var/log/salt/orchestrate_runner'
    - require:
      - salt: {{ state.0 }}

{{ state.0 }}.logfail:
  salt.function:
    - tgt: 'I@salt:master or I@{{ state.0|replace(".", ":") }}'
    - tgt_type: compound
    - queue: True
    - name: cmd.run
    - arg:
      - 'echo "$(date +"%d %h %Y %H:%M:%S") | state: {{ state.0}} - status: FAIL" >> /var/log/salt/orchestrate_runner'
    - onfail:
      - salt: {{ state.0 }}

            {%- endif %}
          {%- endif %}
        {%- endif %}

      {%- endfor %}

    {%- endif %}
  {%- endfor %}
{%- endif %}

