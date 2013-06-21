if [ -x /usr/sbin/mdata-get ]; then
  HAS_METADATA=yes

  log "waiting for metadata to show up"

  until [ -e /.zonecontrol/metadata.sock ] ||\
        [ -e /var/run/smartdc/metadata.sock ] ||\
        [ $((MCOUNT++)) -gt 30 ]; do
    sleep 1
  done

  [ -e /.zonecontrol/metadata.sock ] ||\
  [ -e /var/run/smartdc/metadata.sock ] ||\
    log "metadata failed to show up"
fi
