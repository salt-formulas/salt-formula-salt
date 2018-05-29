
haproxy_config:
  file.managed:
    - name: /tmp/haproxy_config
    - contents: |
{%- for server, addrs in salt['mine.get']('roles:salt:master', 'grains.items', expr_form='pillar').items() %}
        server {{ server }} {{ addrs[0] }}:80 check
{%- endfor %} 
    - template: jinja