salt:
  master:
    enabled: true
    ssh_minion:
      node01:
        host: 10.0.0.1
        user: saltssh
        sudo: true
        key_file: /path/to/the/key
        port: 22
