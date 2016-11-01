{%- from "salt/map.jinja" import master with context %}

{%- if master.enabled %}
  {%- for environment_name, environment in master.get('environment', {}).iteritems() %}
    {%- if master.base_environment == environment_name %}
      {%- set priorities = {} %}
      {%- set args = {} %}
      {%- set formulas = environment.get('formula', {}) %}

      {%- for formula_name, formula in formulas.iteritems() %}
        {%- if salt['file.file_exists'](master.dir.files+'/'+environment_name+'/'+formula_name+'/meta/salt.yml') %}
          {%- set grains_fragment_file = formula_name+'/meta/salt.yml' %}
          {%- macro load_grains_file() %}{% include grains_fragment_file %}{% endmacro %}
          {%- set grains_yaml = load_grains_file()|load_yaml %}

          {%- for state, priority in grains_yaml['orchestrate'].iteritems() %}
            {%- do priorities.update({ formula_name+'.'+state: grains_yaml['orchestrate'][state]['priority'] }) %}
            {%- set arguments = [] %}

            {%- for arg_name, arg_value in grains_yaml['orchestrate'][state].iteritems() %}
              {%- if 'priority' not in arg_name %}
                {%- do arguments.append({arg_name: arg_value}) %}
              {%- endif %}
            {%- endfor %}

            {%- if arguments %}
              {%- do args.update({ formula_name+'.'+state: arguments }) %}
            {%- endif %}
          {%- endfor %}
        {%- else %}
          {%- do priorities.update({ formula_name: 10000 }) %}
        {%- endif %}
      {%- endfor %}

{{ master.dir.files }}/{{ environment_name }}/orchestrate:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{{ master.dir.files }}/{{ environment_name }}/orchestrate/init.sls:
  file.managed:
  - source: salt://salt/files/orchestrate.sls
  - user: root
  - template: jinja
  - defaults:
      priorities: {{ priorities }}
      args: {{ args }}

    {%- endif %}
  {%- endfor %}
{%- endif %}

