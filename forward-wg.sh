PORT=55953
IF=enp0s3
WG=wghub
SRC_IP=10.0.0.64
DST_IP=10.196.150.11

# UDP port
iptables -A FORWARD -i $IF -o $WG -p udp --dport $PORT -j ACCEPT
iptables -t nat -A PREROUTING -i $IF -p udp --dport $PORT -j DNAT --to-destination $DST_IP
iptables -t nat -A POSTROUTING -o $WG -p udp --dport $PORT -d $DST_IP -j SNAT --to-source $SRC_IP

# TCP port
iptables -A FORWARD -i $IF -o $WG -p tcp --syn --dport $PORT -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -i $IF -o $WG -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $WG -o $IF -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A PREROUTING -i $IF -p tcp --dport $PORT -j DNAT --to-destination $DST_IP
iptables -t nat -A POSTROUTING -o $WG -p tcp --dport $PORT -d $DST_IP -j SNAT --to-source $SRC_IP
