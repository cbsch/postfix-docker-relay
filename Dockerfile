ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE}


RUN true && \
    export DEBIAN_FRONTEND=noninteractive && \
    echo "Europe/Berlin" > /etc/timezone && \
    apt-get update -y -q && \
    apt-get install -y ca-certificates tzdata supervisor && \
    apt-get install -y postfix;

RUN apt-get install -y rsyslog
RUN apt-get install -y bash
RUN apt-get install -y vim
RUN apt-get install -y dovecot-core

# Cli tools for debugging / testing
RUN apt-get install -y dnsutils
RUN apt-get install -y net-tools

# HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD printf "EHLO healthcheck\n" | nc 127.0.0.1 587 | grep -qE "^220.*ESMTP Postfix"

RUN echo 'example.lan #domain' > /etc/postfix/virtual_mailbox_domains
RUN postmap /etc/postfix/virtual_mailbox_domains
RUN echo 'user@example.lan:{plain}testpass' > /etc/dovecot/users

COPY config/supervisord/supervisord.conf /etc/supervisord.conf
COPY config/rsyslog/rsyslog.conf /etc/rsyslog.conf
COPY config/postfix/* /etc/postfix/

RUN cp -f /etc/services /var/spool/postfix/etc/services
RUN cp -f /etc/resolv.conf /var/spool/postfix/etc/resolv.conf

COPY config/dovecot/* /etc/dovecot/conf.d/

EXPOSE 25
CMD exec supervisord -c /etc/supervisord.conf
