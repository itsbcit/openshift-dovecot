[ -f $TLS_KEY ] && return

OPENSSL=/usr/bin/openssl
OPENSSLCONFIG=$CONFDIR/dovecot-openssl.cnf

# alpine dovecot.post-install
$OPENSSL req -new -x509 -nodes -config $OPENSSLCONFIG -out $TLS_CERT -keyout $TLS_KEY -days 365 || exit 2
chmod 0600 $TLS_KEY

$OPENSSL x509 -subject -fingerprint -noout -in $TLS_CERT || exit 2
