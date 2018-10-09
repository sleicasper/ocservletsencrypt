#!/bin/sh


# Open ipv4 ip forward
sysctl -w net.ipv4.ip_forward=1

# Enable NAT forwarding
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# Enable TUN device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

while true
do
	if [ -f /etc/letsencrypt/archive/$DOMAIN_NAME/fullchain1.pem ];then
		echo cert exist
	else
		certbot certonly --standalone --email $EMAIL_ADDRESS -d $DOMAIN_NAME --user-agent "" --agree-tos --noninteractive --text --verbose --debug
	fi

	timeout 86400s ocserv -c /etc/ocserv/ocserv.conf -f
	certbot certonly --standalone --email $EMAIL_ADDRESS -d $DOMAIN_NAME --user-agent "" --agree-tos --noninteractive --text --verbose --debug
done
