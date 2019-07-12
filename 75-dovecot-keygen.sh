[ -f /etc/ssl/dovecot/server.key ] && return

OPENSSL=/usr/bin/openssl
OPENSSLCONFIG=/etc/dovecot/dovecot-openssl.cnf

if [ -f $OPENSSLCONFIG ]; then
	# alpine dovecot.post-install
	$OPENSSL req -new -x509 -nodes -config $OPENSSLCONFIG -out /etc/ssl/dovecot/server.pem -keyout /etc/ssl/dovecot/server.key -days 365 || exit 2
	chmod 0600 /etc/ssl/dovecot/server.key
	$OPENSSL x509 -subject -fingerprint -noout -in /etc/ssl/dovecot/server.pem || exit 2
fi
