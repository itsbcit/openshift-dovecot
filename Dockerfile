FROM bcit/alpine:3.9-supervisord
LABEL maintainer="jesse@weisner.ca, Juraj Ontkanin"
LABEL build_id="1567137415"

ENV DOCKERIZE_ENV production

ENV VERSION "2.3.7.2-r0"

ENV CONFIGDIR /config
ENV CONFIGDIR_D /config-d
ENV CONFIGDIR_PROTO /config-proto
ENV CONFIGDIR_SSL /config-ssl

ENV RUNUSER dovecot
ENV HOME /var/lib/dovecot

ENV VMAIL_USER vmail
ENV VMAIL_UID 10001
ENV VMAIL_GROUP vmail
ENV VMAIL_GID 10001

ENV VMAIL_DATA /data/vmail
ENV VMAIL_INDEX /data/index


RUN apk add --no-cache \
    libcap \
    dovecot=2.3.7.2-r0 \
    dovecot-fts-solr=2.3.7.2-r0 \
    dovecot-ldap=2.3.7.2-r0 \
    dovecot-lmtpd=2.3.7.2-r0 \
    dovecot-pigeonhole-plugin=2.3.7.2-r0 \
    dovecot-pop3d=2.3.7.2-r0 \
    dovecot-submissiond=2.3.7.2-r0

RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/dovecot

RUN mkdir -p \
    "${CONFIGDIR}" \
    "${CONFIGDIR_D}" \
    "${CONFIGDIR_PROTO}" \
    "${CONFIGDIR_SSL}"

RUN addgroup -g $VMAIL_GID -S $VMAIL_GROUP \
 && adduser -u $VMAIL_UID -G $VMAIL_GROUP -H -h /dev/null -s /sbin/nologin -S $VMAIL_USER

RUN mkdir -p \
    "$VMAIL_DATA" \
    "$VMAIL_INDEX" \
 && chown ${VMAIL_UID}:${VMAIL_GID} \
    "$VMAIL_DATA" \
    "$VMAIL_INDEX" \
 && chmod 775 \
    "$VMAIL_DATA" \
    "$VMAIL_INDEX"

RUN sed -i "s/^#\s*listen\s*=.*/listen = \*/g" /etc/dovecot/dovecot.conf \
 && sed -i "s;^#\s*base_dir\s*=.*;base_dir = /run/dovecot/;g" /etc/dovecot/dovecot.conf \
 && sed -i "s/^#\s*default_login_user\s*=.*/default_login_user = ${RUNUSER}/g" /etc/dovecot/conf.d/10-master.conf \
 && sed -i "s/^#\s*default_internal_user\s*=.*/default_internal_user = ${RUNUSER}\ndefault_internal_group = root/g" /etc/dovecot/conf.d/10-master.conf

## Configuration: /usr/share/dovecot/protocols.d
RUN cp --dereference -r /usr/share/dovecot/protocols.d/* "${CONFIGDIR_PROTO}"/ \
 && rm -rf /usr/share/dovecot/protocols.d \
 && mkdir -p /usr/share/dovecot/protocols.d \
 && chown 0:0 /usr/share/dovecot/protocols.d \
 && chmod 775 /usr/share/dovecot/protocols.d

## Configuration: /etc/dovecot/conf.d
RUN cp --dereference -r /etc/dovecot/conf.d/* "${CONFIGDIR_D}"/ \
 && rm -rf /etc/dovecot/conf.d

## Configuration: /etc/dovecot
RUN cp --dereference -r /etc/dovecot/* "${CONFIGDIR}"/ \
 && rm -rf /etc/dovecot \
 && mkdir -p /etc/dovecot/conf.d \
 && chown -R 0:0 /etc/dovecot \
 && chmod -R 775 /etc/dovecot

## Certificates
RUN rm -rf /etc/ssl/dovecot \
 && mkdir -p /etc/ssl/dovecot \
 && chown 0:0 /etc/ssl/dovecot \
 && chmod 770 /etc/ssl/dovecot

## Runtime
RUN rm -rf /var/lib/dovecot /run \
 && mkdir -p /var/lib/dovecot /run \
 && chown 0:0 /var/lib/dovecot /run \
 && chmod 775 /var/lib/dovecot \
 && chmod 1777 /run

VOLUME "$VMAIL_DATA"
VOLUME "$VMAIL_INDEX"

VOLUME /var/lib/dovecot
VOLUME /run

WORKDIR /var/lib/dovecot

COPY 70-dovecot-conf.sh /docker-entrypoint.d/70-dovecot-conf.sh
COPY 75-dovecot-keygen.sh /docker-entrypoint.d/75-dovecot-keygen.sh

EXPOSE 143 993

CMD ["/usr/sbin/dovecot", "-F"]
