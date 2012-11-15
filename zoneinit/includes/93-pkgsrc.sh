if [ "${NETWORKING}" == "yes" ]; then
  log "updating pkgin database"
  pkgin -f -y update >/dev/null || true
fi
