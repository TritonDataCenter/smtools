log "sourcing the basic machine configuration"

if [ -f "${ZONECONFIG}" ]; then
  source ${ZONECONFIG}
else
  error "ERROR ${ZONECONFIG} not present. Aborting." 96
fi

log "setting variables and machine size"
: ${ZONENAME:=$(zonename)}
: ${HOSTNAME:=${ZONENAME}.joyent.us}

# Machine memory and swap limits are retrieved using kstat. Historically, they
# were also passed in 'zoneconfig'. If the limit cannot be retrieved, settle
# for a 128/256 MiB sized machine.

if [ -z "${RAM_IN_BYTES}" ]; then
  RAM_IN_BYTES=$( kstat -p -c zone_memory_cap -s physcap | awk '{print $2}' )
  if ! [ ${RAM_IN_BYTES} -gt 0 2>/dev/null ]; then
    RAM_IN_BYTES=134217728
  fi
  log "zone physical memory cap determined as $((RAM_IN_BYTES/1024/1024)) MiB"
fi

if [ -z "${SWAP_IN_BYTES}" ]; then
  SWAP_IN_BYTES=$( kstat -p -c zone_memory_cap -s swapcap | awk '{print $2}' )
  if ! [ ${SWAP_IN_BYTES} -gt 0 2>/dev/null ]; then
    SWAP_IN_BYTES=$((RAM_IN_BYTES*2))
  fi
  log "zone virtual memory cap determined as $((SWAP_IN_BYTES/1024/1024)) MiB"
fi

if [ ! ${TMPFS} ]; then
  TMPFS=$((RAM_IN_BYTES/1024/1024))
fi
