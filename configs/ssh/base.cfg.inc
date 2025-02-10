# This file contains my preferred default SSH client configuration. It hardens a few settings while
# allowing some conveniences such as TOFU for systems in a DNSSEC signed zone and a published SSHFP
# record.

Host *
  AddKeysToAgent yes

  ControlMaster auto
  ControlPath ~/.ssh/cm-%r@%h:%p
  ControlPersist 5m

  ServerAliveInterval 60
  ServerAliveCountMax 10
  ConnectTimeout 30

  IdentitiesOnly yes
  VerifyHostKeyDNS ask
  UpdateHostKeys yes
  StrictHostKeyChecking ask
  HashKnownHosts yes

  ForwardAgent no
  ForwardX11 no
  ForwardX11Trusted no

  GatewayPorts no
  RekeyLimit 512M 1H
