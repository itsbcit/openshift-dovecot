FROM bcit/alpine:3.9
# vim: syntax=dockerfile

LABEL maintainer="jesse_weisner@bcit.ca, Juraj Ontkanin"
LABEL version="2.3.6-r0"

ENV VERSION "2.3.6-r0"
ENV CONFDIR /etc/dovecot
ENV CONFDROPDIR /etc/dovecot.d
ENV PROTODROPDIR /etc/dovecot-protocols.d
ENV LOCALSTATEDIR /var/lib/dovecot
ENV SECRETSDIR /etc/ssl/dovecot
ENV PIDDIR /run
ENV RUNUSER dovecot
ENV HOME $LOCALSTATEDIR
ENV TLS_KEY /etc/ssl/dovecot/server.key
ENV TLS_CERT /etc/ssl/dovecot/server.pem
ENV VMAIL_USER vmail
ENV VMAIL_UID 10001
ENV VMAIL_GROUP vmail
ENV VMAIL_GID 10001

RUN apk add --no-cache \
    libcap \
    dovecot=2.3.6-r0 \
    dovecot-fts-solr=2.3.6-r0 \
    dovecot-ldap=2.3.6-r0 \
    dovecot-lmtpd=2.3.6-r0 \
    dovecot-pigeonhole-plugin=2.3.6-r0 \
    dovecot-pop3d=2.3.6-r0 \
    dovecot-submissiond=2.3.6-r0

RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/dovecot

COPY dovecot.conf $CONFDIR/dovecot.conf
COPY 10-master.conf $CONFDIR/conf.d/10-master.conf

RUN touch /usr/share/dovecot/protocols.d/.keep \
 && tar czf /dovecot-protocols.tar.gz -C /usr/share/dovecot/protocols.d . \
 && mkdir $PROTODROPDIR \
 && chown 0:0 $PROTODROPDIR \
 && chmod 775 $PROTODROPDIR

RUN touch $CONFDIR/conf.d/.keep \
 && tar czf /dovecot-confdrop.tar.gz -C $CONFDIR/conf.d . \
 && rm -rf $CONFDIR/conf.d \
 && mkdir $CONFDROPDIR \
 && chown 0:0 $CONFDROPDIR \
 && chmod 775 $CONFDROPDIR


RUN touch $CONFDIR/.keep \
 && tar czf /dovecot-conf.tar.gz -C $CONFDIR . \
 && rm -rf $CONFDIR $SECRETSDIR $LOCALSTATEDIR $PIDDIR \
 && mkdir $CONFDIR $SECRETSDIR $LOCALSTATEDIR $PIDDIR \
 && chown 0:0 $CONFDIR $SECRETSDIR $LOCALSTATEDIR $PIDDIR \
 && chmod 775 $CONFDIR $LOCALSTATEDIR $PIDDIR \
 && chmod 770 $SECRETSDIR

RUN chmod 1777 /run

RUN addgroup -g $VMAIL_GID -S $VMAIL_GROUP \
 && adduser -u $VMAIL_UID -G $VMAIL_GROUP -H -h /dev/null -s /sbin/nologin -S $VMAIL_USER

VOLUME $CONFDIR
VOLUME $CONFDROPDIR
VOLUME $PROTODROPDIR
VOLUME $SECRETSDIR
VOLUME $LOCALSTATEDIR
VOLUME $PIDDIR
VOLUME /run

WORKDIR $HOME

COPY 70-dovecot-conf.sh /docker-entrypoint.d/70-dovecot-conf.sh
COPY 75-dovecot-keygen.sh /docker-entrypoint.d/75-dovecot-keygen.sh

EXPOSE 143 993

CMD ["/usr/sbin/dovecot", "-F"]
