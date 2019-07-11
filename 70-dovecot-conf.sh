[ -f ${CONFDIR}/.keep ] || tar zxf /dovecot-conf.tar.gz -C ${CONFDIR}
[ -f ${CONFDROPDIR}/.keep ] || tar zxf /dovecot-confdrop.tar.gz -C ${CONFDROPDIR}
[ -f ${PROTODROPDIR}/.keep ] || tar zxf /dovecot-protocols.tar.gz -C ${PROTODROPDIR}

if [ -f "$CONFDIR"/.DOCKERIZE.env ]; then
    echo "loading: ${CONFDIR}/.DOCKERIZE.env"
    . "$CONFDIR"/.DOCKERIZE.env
fi
for tmpl_file in $( find "${CONFDIR}" "${CONFDROPDIR}" "${PROTODROPDIR}" -type f -name '*.tmpl' -not -path '*/\.git/*' ); do
    config_file="$( dirname -- "$tmpl_file" )/$( basename -- "$tmpl_file" .tmpl )"
    echo "dockerizing: ${tmpl_file}"
    echo "         =>  ${config_file}"
    dockerize -template "$tmpl_file":"$config_file" \
    && rm -f "$tmpl_file"
done
