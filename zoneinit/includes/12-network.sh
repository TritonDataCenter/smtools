log "setting hostname, IPs and resolvers"

echo "${HOSTNAME}" > /etc/nodename
/bin/hostname ${HOSTNAME}

(
/bin/sed '/nameserver/d' /etc/resolv.conf 2>/dev/null
for HOST in ${RESOLVERS[@]}; do
  echo "nameserver ${HOST}"
done
) > /etc/resolv.conf.tmp
mv /etc/resolv.conf{.tmp,}

sed '/^127\.0\.0\.1/s/$/ '${HOSTNAME}'/' /etc/inet/hosts > /etc/inet/hosts.tmp
mv /etc/inet/hosts{.tmp,}

log "checking if we can reach the Internets"

if dig www.joyent.com +short +time=2 +tries=1 >/dev/null 2>&1 && \
   ping www.joyent.com 2 >/dev/null 2>&1 && \
   curl -m 5 -s -I http://www.joyent.com >/dev/null; then
  NETWORKING=yes
else
  NETWORKING=no
  log "continuing with no apparent Internet access"
fi
