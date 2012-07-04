if [ ${HAS_METADATA} ]; then
  log "enabling metadata agent"

  svcadm enable mdata:fetch
fi
