#!/bin/bash

apt-get install -y gpg2

sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh)

# Need to login to nordvpn before the service will
# actually work
cat << NORDVPN > /etc/systemd/system/nordvpn.service
[Unit]
Requires=network-online.target

[Service]
RemainAfterExit=yes
ExecStartPre=nordvpn whitelist add subnet 192.168.1.0/24
ExecStart=nordvpn connect P2P
ExecStop=nordvpn disconnect

[Install]
WantedBy=multi-user.target
NORDVPN

systemctl daemon-reload
systemctl enable nordvpn
systemctl start nordvpn