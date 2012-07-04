log "parsing IP information"

i=-1
while ((i++))
      IFACE=NET${i}_INTERFACE
      [ ${!IFACE} ]; do
  NET_INTERFACES=(${NET_INTERFACES[@]} NET${i})
done

log "provisioner passed ${#NET_INTERFACES[@]} network interfaces"

if [ ${#NET_INTERFACES} -eq 0 ]; then

  # Networks are unknown. Try the old PUBLIC_IP/PRIVATE_IP friends,
  # otherwise loop through interfaces available and try to sort out
  # public IPs from private IPs. Worst case, private IP will be the
  # same as public (e.g. when the zone is provisioned with only one
  # interface set up).

  log "falling back to dirty network interface discovery"

  if [ -z "${PUBLIC_IP}" ]; then
    for IP in $(ifconfig -a|awk '{if($1=="inet")print $2}'); do
      case ${IP} in
        127.*) LOCALS=(${LOCALS[@]} ${IP});;
        10.*|172.1[6-9].*|172.2[0-9].*|172.3[0-1].*|192.168.*)
               PRIVATES=(${PRIVATES[@]} ${IP});;
        *)     PUBLICS=(${PUBLICS[@]} ${IP});;
      esac
    done
    PUBLIC_POOL=(${PUBLICS[@]} ${PRIVATES[@]})
    PUBLIC_IP=${PUBLIC_POOL[0]}
    PRIVATE_POOL=(${PRIVATES[@]} ${PUBLICS[@]})
    for ((i=0; i<${#PRIVATE_POOL[@]}; i++)); do
      [ ! ${PRIVATE_POOL[$i]} == "${PUBLIC_IP}" ] || continue
      PRIVATE_IP=${PRIVATE_POOL[$i]}
    done
  fi
  if [ ${PUBLIC_IP} ]; then
    NET0_IP=${PUBLIC_IP}
    NET_INTERFACES=(NET0)
    if [ -z "${PRIVATE_IP}" ]; then
      PRIVATE_IP=${PUBLIC_IP}
    else
      NET1_IP=${PRIVATE_IP}
      NET_INTERFACES=(${NET_INTERFACES[@]} NET1)
    fi
  fi
  log "discovered ${#NET_INTERFACES[@]} network interfaces"
fi

