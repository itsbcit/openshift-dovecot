[ -f ${CONFDIR}/.keep ] || tar zxf /dovecot-conf.tar.gz -C ${CONFDIR}
[ -f ${CONFDROPDIR}/.keep ] || tar zxf /dovecot-confdrop.tar.gz -C ${CONFDROPDIR}
[ -f ${PROTODROPDIR}/.keep ] || tar zxf /dovecot-protocols.tar.gz -C ${PROTODROPDIR}

if [ -f "$CONFDIR"/.DOCKERIZE.env ]; then
    echo "loading ${CONFDIR}/.DOCKERIZE.env environment"
    . "$CONFDIR"/.DOCKERIZE.env
fi
for config_file in $( find "${CONFDIR}" "${CONFDROPDIR}" "${PROTODROPDIR}" -type f ); do 
    dockerize -template "$config_file":"$config_file"
done
