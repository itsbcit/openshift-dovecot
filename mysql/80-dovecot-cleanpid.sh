PID_DOVECOT="/run/dovecot/master.pid"

if [ -f ${PID_DOVECOT} ]; then
    echo "removing: ${PID_DOVECOT}"
    rm -f ${PID_DOVECOT}
fi
