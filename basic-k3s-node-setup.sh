#!/bin/bash

cat <<EOF | tee /etc/sysctl.d/10-k3s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1

# https://github.com/kubernetes/kubernetes/issues/64315
fs.inotify.max_user_watches         = 16384
fs.inotify.max_user_instances       = 8192
EOF

sysctl --system

# Add backports repo
grep bookworm-backports /etc/apt/sources/list
if [[ "$?" != "0" ]]; then
  sed -i '$a\
deb http://deb.debian.org/debian bookworm-backports main
' /etc/apt/sources.list
fi

apt-get update

# (Optional) Install newer kernel from backports
# apt-get install -y -t bookworm-backports linux-image-amd64

apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  nfs-common \
  open-iscsi

systemctl enable open-iscsi
systemctl start open-iscsi

