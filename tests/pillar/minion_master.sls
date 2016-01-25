salt:
  minion:
    enabled: true
    master:
      host: 127.0.0.1
    mine:
      interval: 60
      module:
        grains.items: []
        network.interfaces: []
