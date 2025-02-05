FROM alpine:latest
RUN apk --no-cache add --update openvpn iptables socat curl openssl obfsproxy
ADD ./bin /usr/local/sbin
VOLUME /etc/openvpn
EXPOSE 443/tcp 1194/udp 8080/tcp
CMD ["run"]