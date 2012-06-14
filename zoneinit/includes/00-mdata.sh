log "waiting for metadata to show up"

until [ -e /var/run/smartdc/metadata.sock ] || [ $((MCOUNT++)) -gt 30 ]; do
  sleep 1
done

[ -e /var/run/smartdc/metadata.sock ] || log "metadata failed to show up"
