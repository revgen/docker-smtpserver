#!/bin/sh

[ "${DEBUG:-"no"}" = "yes" ] && set -x

SERVER_HOSTNAME="${SERVER_HOSTNAME:-"localhost"}"
SMTP_SERVER="${SMTP_SERVER:-"smtp.gmail.com"}"
SMTP_PORT="${SMTP_PORT:-465}"
SMTP_USERNAME="${SMTP_USERNAME:-"ChangeMe"}"
SMTP_PASSWORD="${SMTP_PASSWORD:-"ChangeMe"}"
SMTP_NETWORKS="${SMTP_NETWORKS:-"10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16"}"

echo "Start SMTP relay server:"
echo "* SERVER_HOSTNAME = ${SERVER_HOSTNAME}"
echo "* SMTP_SERVER     = ${SMTP_SERVER}"
echo "* SMTP_PORT       = ${SMTP_PORT}"
echo "* SMTP_USERNAME   = ${SMTP_USERNAME}"
echo "* SMTP_PASSWORD   = $(echo "${SMTP_PASSWORD}" | sed 's/./*/g' | head -c 8)"
echo "* SMTP_NETWORKS   = ${SMTP_NETWORKS}"

postconf -e "myhostname = ${SERVER_HOSTNAME}"
postconf -e "relayhost = [${SMTP_SERVER}]:${SMTP_PORT}"
postconf -e "mynetworks = ${SMTP_NETWORKS}"

if [ -z "${SMTP_USERNAME}" ]; then
    postconf -X smtp_sasl_auth_enable smtp_sasl_password_maps smtp_sasl_security_options
else
    postconf -e "smtpd_sasl_local_domain = ${SERVER_HOSTNAME}"
    postconf -e "smtpd_sasl_path = smtpd_sasl_path"
    postconf -e "smtpd_sasl_security_options = noanonymous"

    postconf -e "smtp_sasl_auth_enable = yes"
    postconf -e "smtp_sasl_password_maps = lmdb:/etc/postfix/sasl_passwd"
    postconf -e "smtp_sasl_security_options = noanonymous"
    if ! grep -q "${SMTP_SERVER}" /etc/postfix/sasl_passwd 2> /dev/null; then
        echo "[${SMTP_SERVER}]:${SMTP_PORT} ${SMTP_USERNAME}:${SMTP_PASSWORD}" >> /etc/postfix/sasl_passwd
        postmap /etc/postfix/sasl_passwd
        chmod 600 /etc/postfix/sasl_passwd
    fi
fi

if [ "${SMTP_PORT}" = "465" ]; then
    postconf -e "smtp_tls_wrappermode = yes"
    postconf -e "smtp_tls_security_level = encrypt"
else
    postconf -X smtp_tls_wrappermode smtp_tls_security_level
fi

if [ $$ = 1 ]; then
    rm -f /var/spool/postfix/pid/master.pid
fi

echo "Start SMTP Relay Server: ${SERVER_HOSTNAME}:25."
exec /usr/sbin/postfix -c /etc/postfix start-fg