
node_sync_all:
  local.saltutil.sync_all:
  - tgt: {{ data.id }}

node_refresh_pillar:
  local.saltutil.refresh_pillar:
  - tgt: {{ data.id }}
