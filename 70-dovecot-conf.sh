mkdir -p "$VMAIL_DATA"/.config "$VMAIL_INDEX"
chown ${VMAIL_UID}:${VMAIL_GID} "$VMAIL_DATA" "$VMAIL_INDEX" "$VMAIL_DATA"/.config
chmod 775 "$VMAIL_DATA" "$VMAIL_INDEX" "$VMAIL_DATA"/.config

stat "${CONFIGDIR}"/* >/dev/null 2>&1
[ $? -eq 0 ] && cp --dereference -r "${CONFIGDIR}"/* /etc/dovecot/

stat "${CONFIGDIR_D}"/* >/dev/null 2>&1
[ $? -eq 0 ] && cp --dereference -r "${CONFIGDIR_D}"/* /etc/dovecot/conf.d/

stat "${CONFIGDIR_PROTO}"/* >/dev/null 2>&1
[ $? -eq 0 ] && cp --dereference -r "${CONFIGDIR_PROTO}"/* /usr/share/dovecot/protocols.d/

stat "${CONFIGDIR_SSL}"/* >/dev/null 2>&1
[ $? -eq 0 ] && cp --dereference -r "${CONFIGDIR_SSL}"/* /etc/ssl/dovecot/

if [ -f "$CONFIGDIR"/.DOCKERIZE.env ]; then
    echo "loading: ${CONFIGDIR}/.DOCKERIZE.env"
    . "$CONFIGDIR"/.DOCKERIZE.env
fi
for tmpl_file in $( find /etc/dovecot /usr/share/dovecot/protocols.d /etc/ssl/dovecot -type f -name '*.tmpl' -not -path '*/\.git/*' ); do
    config_file="$( dirname -- "$tmpl_file" )/$( basename -- "$tmpl_file" .tmpl )"
    echo "dockerizing: ${tmpl_file}"
    echo "         =>  ${config_file}"
    dockerize -template "$tmpl_file":"$config_file" \
    && rm -f "$tmpl_file"
done
