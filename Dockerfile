FROM bcit/alpine:3.9
# vim: syntax=dockerfile

LABEL maintainer="jesse_weisner@bcit.ca"
LABEL version="2.3.5.1-r0"

ENV VERSION "2.3.5.1-r0"
ENV CONFDIR /etc/dovecot
ENV CONFDROPDIR /etc/dovecot.d
ENV SECRETSDIR /etc/ssl/dovecot
ENV TLS_KEY /etc/ssl/dovecot/server.key
ENV TLS_CERT /etc/ssl/dovecot/server.pem

RUN apk add --no-cache \
    dovecot=2.3.5.1-r0 \
    dovecot-fts-solr=2.3.5.1-r0 \
    dovecot-ldap=2.3.5.1-r0 \
    dovecot-lmtpd=2.3.5.1-r0 \
    dovecot-pigeonhole-plugin=2.3.5.1-r0 \
    dovecot-pop3d=2.3.5.1-r0 \
    dovecot-submissiond=2.3.5.1-r0

RUN touch $CONFDIR/conf.d/.keep \
 && tar -czf /dovecot-confdrop.tar.gz -C $CONFDIR/conf.d . \
 && rm -rf $CONFDIR/conf.d \
 && mkdir $CONFDROPDIR \
 && chown 0:0 $CONFDROPDIR \
 && chmod 755 $CONFDROPDIR

COPY dovecot.conf.patch /dovecot.conf.patch
RUN patch $CONFDIR/dovecot.conf < /dovecot.conf.patch \
  && rm -f /dovecot.conf.patch

RUN touch $CONFDIR/.keep \
 && tar -czf /dovecot-conf.tar.gz -C $CONFDIR . \
 && rm -rf $CONFDIR $SECRETSDIR \
 && mkdir $CONFDIR $SECRETSDIR \
 && chown 0:0 $CONFDIR $SECRETSDIR \
 && chmod 755 $CONFDIR \
 && chmod 750 $SECRETSDIR

VOLUME $CONFDIR
VOLUME $CONFDROPDIR
VOLUME $SECRETSDIR

COPY 70-dovecot-conf.sh /docker-entrypoint.d/70-dovecot-conf.sh
COPY 75-dovecot-keygen.sh /docker-entrypoint.d/75-dovecot-keygen.sh

EXPOSE 110 143 993 995

CMD ["/usr/sbin/dovecot", "-F"]
