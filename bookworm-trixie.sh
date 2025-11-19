#!/bin/bash

sed -i 's/bookworm/trixie/g' /etc/apt/sources.list

apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -y --with-new-pkgs
DEBIAN_FRONTEND=noninteractive apt autoremove -y
