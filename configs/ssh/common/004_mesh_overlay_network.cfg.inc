Host proxy-server
  Hostname 172.16.50.1
  IdentityFile ~/.ssh/default-system-key

Host 3d-printer
  Hostname 172.16.50.2
  IdentityFile ~/.ssh/default-system-key

Host desktop
  Hostname 172.16.50.3
  ForwardAgent yes
  IdentityFile ~/.ssh/default-system-key

Host old-laptop
  Hostname 172.16.50.4
  ForwardAgent yes
  IdentityFile ~/.ssh/default-system-key

Host work-laptop
  Hostname 172.16.50.5
  ForwardAgent yes
  IdentityFile ~/.ssh/default-system-key

Host framework
  Hostname 172.16.50.11
  ForwardAgent yes
  IdentityFile ~/.ssh/default-system-key

Host roadwarrior-direct
  Hostname 10.100.25.1
  Port 2200
  PubkeyAcceptedAlgorithms +ssh-rsa
  HostKeyAlgorithms +ssh-rsa
  User root

Host roadwarrior-vpn
  Hostname 172.16.50.9
  User root
  Port 2200

  IdentityFile ~/.ssh/default-system-key

  PubkeyAcceptedAlgorithms +ssh-rsa
  HostKeyAlgorithms +ssh-rsa
