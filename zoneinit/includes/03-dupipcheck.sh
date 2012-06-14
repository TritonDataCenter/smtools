log "checking for duplicate IPs"

if ifconfig -a | grep DUP >/dev/null ; then
  error "Provisioned with IP already in use, shutting down."      
  halt
fi