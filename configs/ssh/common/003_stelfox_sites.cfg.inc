Host *.i
  IdentityFile ~/.ssh/default-system-key
  ProxyCommand ssh -q singing-evening-road.stelfox.net "nc 127.0.0.1 $(echo %h | sed 's;\.i$;;')"

Host *.stelfox.net
  IdentityFile ~/.ssh/default-system-key

Host hollow-twilight-ocean.stelfox.net
  Port 2200
  IdentityFile ~/.ssh/default-system-key

Host singing-evening-road.stelfox.net
  Port 2200
  IdentityFile ~/.ssh/default-system-key
