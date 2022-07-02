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


groupadd -g 9199 nyx
useradd -u 9199 nyx -g 9199 -M -d /media/downloads/qbittorrent -s /usr/sbin/nologin

cat << QBITTORRENT > /etc/systemd/system/qbittorrent-nox.service
[Unit]
Requires=network-online.target
Requires=media-downloads.mount
Requires=wg-quick@wgclient_11.service

[Service]
User=nyx
Group=nyx
ExecStart=qbittorrent-nox --profile=/media/downloads/qbittorrent

[Install]
WantedBy=multi-user.target
QBITTORRENT

systemctl daemon-reload
systemctl enable qbittorrent-nox.service
systemctl start qbittorrent-nox.service

# Caddy install
groupadd caddy
useradd caddy -g caddy -s /usr/sbin/nologin -m /var/lib/caddy
install -d /etc/caddy -m 0711 -o caddy -g caddy

wget 'https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fcaddy-dns%2Fcloudflare&idempotency=37371280112808' -O /usr/bin/caddy
chmod 0755 /usr/bin/caddy

umask 077

cat << CADDYFILE > /etc/caddy/Caddyfile
{
    email ryan@alzabo.io
}

nyx.home.whi.te.it {
    tls {
        dns cloudflare {env.CF_API_TOKEN}
        resolvers 0.1.1.1
    }

    # Set this path to your site's directory.
    root * /usr/share/caddy
    
    # Another common task is to set up a reverse proxy:
    reverse_proxy localhost:8080
}
CADDYFILE

cat << CADDYENV >> /etc/caddy/environment
CF_API_TOKEN=
CADDYENV

cat << CADDYSVC > /etc/systemd/system/caddy.service
[Unit]
Description=Caddy
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=caddy
Group=caddy
ExecStart=/usr/bin/caddy run --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE
EnvironmentFile=-/etc/caddy/environment

[Install]
WantedBy=multi-user.target
CADDYSVC

systemctl daemon-reload
systemctl enable caddy.service
systemctl start caddy.service

