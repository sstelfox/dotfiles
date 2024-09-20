[advice]
  detachedHead = false

[apply]
  whitespace = nowarn

[color]
  branch      = auto
  interactive = auto
  diff        = auto
  status      = auto
  ui          = auto

[commit]
  gpgsign = true
  verbose = true

[core]
  autocrlf = input
  safecrlf = false
  editor   = vim
  filemode = true
  pager = delta

[diff]
  algorithm = histogram
  submodule = log

[fetch]
  fsckobjects = true
  prune = true

[gpg]
  program = gpg2

[init]
  defaultBranch = main

[merge]
  conflictStyle = zdiff3

[pull]
  default = current
  rebase = true

[push]
  default = current
  autosetupremote = true

[receive]
  fsckobjects = true

[rerere]
  enabled = true

[status]
  submoduleSummary = true

[submodule]
  recurse = true

[transfer]
  fsckobjects = true

[user]
  useConfigOnly = true

[filter "lfs"]
  clean = git-lfs clean -- %f
  smudge = git-lfs smudge -- %f
  process = git-lfs filter-process
  required = true

[diff "pass-gpg"]
  binary = true
  textconv = gpg2 -d --quiet --yes --compress-algo=none --no-encrypt-to --batch --use-agent
