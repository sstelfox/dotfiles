[user]
  email = sam.stelfox@tulip.co

[core]
  sshCommand = ssh -o IdentityFile=~/.ssh/tulip_id_ed25519

  # Restore the default hooksPath to allow the tulip precommits to trigger. When I have passthrough
  # hooks working I'll want to remove this entry.
  hooksPath =
