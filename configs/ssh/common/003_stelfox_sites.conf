Host *.i
  IdentityFile ~/.ssh/gpg_key.pub
  IdentityFile ~/.ssh/fallback_key.pub
  ProxyCommand ssh -q singing-evening-road.stelfox.net "nc 127.0.0.1 $(echo %h | sed 's;\.i$;;')"

Host *.stelfox.net
  IdentityFile ~/.ssh/gpg_key.pub
  IdentityFile ~/.ssh/fallback_key.pub

Host hollow-twilight-ocean.stelfox.net
  Port 2200
  IdentityFile ~/.ssh/gpg_key.pub
  IdentityFile ~/.ssh/fallback_key.pub

Host singing-evening-road.stelfox.net
  Port 2200
  IdentityFile ~/.ssh/gpg_key.pub
  IdentityFile ~/.ssh/fallback_key.pub
