log "cleaning up"

svcadm disable zoneinit
svccfg delete -f zoneinit
rm -rf ${ZONECONFIG} ${BASE}/*

log "scheduling an immediate reboot"
echo "reboot >/dev/null" | at now >/dev/null
