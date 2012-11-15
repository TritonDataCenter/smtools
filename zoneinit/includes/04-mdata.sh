if [ ${HAS_METADATA} ]; then

  # Enable the mdata service that fetches the metadata user-script on each boot
  log "enabling metadata agent"
  svcadm enable mdata:fetch

fi
