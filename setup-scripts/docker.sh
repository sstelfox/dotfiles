#!/bin/bash

set -o errexit

if [ ${EUID} != 0 ]; then
  echo "This setup script is expecting to run as root."
  exit 1
fi

echo "WARNING: You should have switched to podman by now... You're being lazy"
echo "and not fixing something if you're running this script..."

if ! grep -q docker /etc/group; then
  groupadd -r docker
fi

if ! groups | grep -q docker; then
  usermod -aG docker sstelfox
fi

dnf install docker -y

if [ "${VERSION_ID}" -ge 31 ]; then
  echo "Fedora 31 and later are using the unified cgroup hierarchy which isn't supported by docker."
  echo "To get docker to work a kernel parameter needs to be set which this script won't do automatically"
  echo "because at this point you shouldn't be using docker you clod."
  echo
  echo "If you really really want to keep going with this you'll need to run the following command,"
  echo "reboot, then enable/start docker yourself. I'm making you work for it idiot."
  echo
  echo "\tsudo grubby --update-kernel=ALL --args='systemd.unified_cgroup_hierarchy=0'"
else
  systemctl enable docker.service
  systemctl start docker.service
fi
