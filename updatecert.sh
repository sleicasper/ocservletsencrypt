

while true
do
	sleep 86400
	certbot certonly --standalone --email $EMAIL_ADDRESS -d $DOMAIN_NAME --user-agent "" --agree-tos --noninteractive --text --verbose --debug
done
