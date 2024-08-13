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

apt-get update

apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  nfs-common \
  open-iscsi

systemctl enable open-iscsi
systemctl start open-iscsi

