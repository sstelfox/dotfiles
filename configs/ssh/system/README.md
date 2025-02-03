# System Specific SSH Configuration

This directory has all of its contents other than this file ignored. The intention here is to allow
dropping in SSH configs relevant only to one or a subset of normal hosts that have this set of
dotfiles installed.

Files created in this directory with the intent of becoming part of your SSH config should:

* Be valid SSH client configuration files (see: `man ssh_config`)
* Have the suffix `.cfg.inc`, all other files will be ignored. This is primarily here to support
  disabling of specific configs without loosing their contents.

These will be appended to the end after the base and common configs. After making any changes you
should rebuild your SSH config using the personal library command `rebuild_ssh_config`. This can be
done with the following command in a shell with these dotfiles active:

```sh
$ _plc rebuild_ssh_config
```

_**CHANGES WILL NOT TAKE EFFECT UNTIL YOU RUN THE ABOVE COMMAND**_

At this time no validation is performed on the config, if your SSH config breaks due to a bad
config... It's a skill issue.
