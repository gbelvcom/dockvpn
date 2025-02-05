FROM alpine:latest
RUN apk --no-cache add --update openvpn iptables socat curl openssl go git
RUN git clone https://github.com/gbelvcom/obfs4.git /tmp/obfs4 \
    && cd /tmp/obfs4/obfs4proxy \
    && go build -o /usr/local/bin/obfs4proxy \
    && chmod +x /usr/local/bin/obfs4proxy \
    && rm -rf /tmp/obfs4
ADD ./bin /usr/local/sbin
VOLUME /etc/openvpn
EXPOSE 443/tcp 1194/udp 8080/tcp
CMD ["run"]