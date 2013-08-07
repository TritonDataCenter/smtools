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
