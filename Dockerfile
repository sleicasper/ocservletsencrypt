FROM ubuntu:18.04

MAINTAINER Casper

ENV OCSERV_VERSION=0.12.1
ENV DOMAIN_NAME=example.com
ENV EMAIL_ADDRESS=test@youremailaddress

WORKDIR /

RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install -y curl build-essential pkg-config gnutls-dev libev-dev libnl-3-dev libseccomp-dev liblz4-dev libreadline-dev iptables gnutls-bin vim certbot
RUN curl -SL "ftp://ftp.infradead.org/pub/ocserv/ocserv-$OCSERV_VERSION.tar.xz" -o ocserv.tar.xz 
RUN curl -SL "ftp://ftp.infradead.org/pub/ocserv/ocserv-$OCSERV_VERSION.tar.xz.sig" -o ocserv.tar.xz.sig 
RUN mkdir -p /usr/src/ocserv 
RUN tar -xf ocserv.tar.xz -C /usr/src/ocserv --strip-components=1 
RUN rm ocserv.tar.xz* 
RUN cd /usr/src/ocserv && ./configure && make && make install
RUN mkdir -p /etc/ocserv
RUN cp /usr/src/ocserv/doc/sample.config /etc/ocserv/ocserv.conf

RUN sed -i 's/\.\/sample\.passwd/\/etc\/ocserv\/ocpasswd/' /etc/ocserv/ocserv.conf 
RUN sed -i 's/\(max-same-clients = \)2/\110/' /etc/ocserv/ocserv.conf 
RUN sed -i 's/\.\.\/tests/\/etc\/ocserv/' /etc/ocserv/ocserv.conf 
RUN sed -i 's/#\(compression.*\)/\1/' /etc/ocserv/ocserv.conf 
RUN sed -i '/^ipv4-network = /{s/192.168.1.0/10.245.99.0/}' /etc/ocserv/ocserv.conf 
RUN sed -i 's/192.168.1.2/8.8.8.8/' /etc/ocserv/ocserv.conf 
RUN sed -i 's/^ca-cert/#ca-cert/' /etc/ocserv/ocserv.conf 
RUN sed -i 's/^route/#route/' /etc/ocserv/ocserv.conf 
RUN sed -i 's/^no-route/#no-route/' /etc/ocserv/ocserv.conf 
RUN sed -i '/\[vhost:www.example.com\]/,$d' /etc/ocserv/ocserv.conf 
RUN sed -i 's/^server-cert/#server-cert/' /etc/ocserv/ocserv.conf 
RUN sed -i 's/^server-key/#server-key/' /etc/ocserv/ocserv.conf 
RUN echo "server-cert = /etc/letsencrypt/archive/$DOMAIN_NAME/fullchain1.pem" >> /etc/ocserv/ocserv.conf 
RUN echo "server-key = /etc/letsencrypt/archive/$DOMAIN_NAME/privkey1.pem" >> /etc/ocserv/ocserv.conf 
RUN echo 'test:Route,All:$5$DktJBFKobxCFd7wN$sn.bVw8ytyAaNamO.CvgBvkzDiFR6DaHdUzcif52KK7' > /etc/ocserv/ocpasswd

RUN echo "default-select-group = All" >> /etc/ocserv/ocserv.conf 
RUN echo "select-group = Route" >> /etc/ocserv/ocserv.conf 
RUN echo "auto-select-group = true" >> /etc/ocserv/ocserv.conf 
RUN echo "config-per-group = /etc/ocserv/config-per-group" >> /etc/ocserv/ocserv.conf 
RUN mkdir -p /etc/ocserv/config-per-group

COPY All /etc/ocserv/config-per-group/All
COPY Route /etc/ocserv/config-per-group/Route


EXPOSE 80
EXPOSE 443
COPY updatecert.sh /updatecert.sh
COPY entry.sh /entry.sh
RUN chmod +x /updatecert.sh
RUN chmod +x /entry.sh
ENTRYPOINT ["/entry.sh"]


