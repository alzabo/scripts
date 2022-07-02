#!/bin/bash
#
apt install -y nfs-client

DOWNLOADS_NFS_SERVER=${DOWNLOADS_NFS_SERVER-192.168.1.10}

cat << MNT > /etc/systemd/system/media-downloads.mount
[Unit]
After=network.target

[Mount]
What=${DOWNLOADS_NFS_SERVER}:/media/downloads
Where=/media/downloads
Type=nfs
Options=_netdev,auto

[Install]
WantedBy=multi-user.target
MNT

systemctl daemon-reload
systemctl enable media-downloads.mount
systemctl start media-downloads.mount
