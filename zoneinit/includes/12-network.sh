log "setting hostname, IPs and resolvers"

: ${RESOLVERS:=8.8.8.8 8.8.4.4}
RESOLVERS=(${RESOLVERS})

echo "${HOSTNAME}" > /etc/nodename
/bin/hostname ${HOSTNAME}

sed '/nameserver/d' /etc/resolv.conf > /tmp/resolv.conf.tmp && \
  mv /tmp/resolv.conf.tmp /etc/resolv.conf
for HOST in ${RESOLVERS[@]}; do
  echo "nameserver ${HOST}" >> /etc/resolv.conf
done

if [ ${#NET_INTERFACES[@]} -gt 0 ]; then
  echo "${NET0_IP}"$'\t'"${HOSTNAME}" >> /etc/inet/hosts
  if [ ${#NET_INTERFACES[@]} -gt 1 ]; then
    echo "${NET1_IP}"$'\t'"${ZONENAME}"$'\t'"loghost" >> /etc/inet/hosts
  fi
fi

log "checking if we can reach the Internets"

NETWORKING=no
if dig www.joyent.com +short +time=2 +tries=1 >/dev/null 2>&1 && \
   ping www.joyent.com 2 >/dev/null 2>&1 && \
   curl -m 5 -s -I http://www.joyent.com >/dev/null; then
  NETWORKING=yes
else
  log "continuing with no apparent Internet access"
fi
