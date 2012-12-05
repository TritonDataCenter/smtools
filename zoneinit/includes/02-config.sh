log "determine machine parameters and configuration"

# Little helper to overcome the problem that mdata-get doesn't use stderr
mdata() {
  set -o pipefail
  output=$(mdata-get $1 2>/dev/null) && echo -e "${output}" || return 1
}

log "checking for duplicate IPs"

if ifconfig -a | grep DUP >/dev/null ; then
  log "provisioned with IP already in use, shutting down."      
  halt
fi

( [ ${HAS_METADATA} ] && mdata sdc:uuid >/dev/null ) || USE_ZONECONFIG=yes

if [ ! ${USE_ZONECONFIG} ]; then

  # This is a recent enough platform to use metadata to retrieve all
  # information we need for provisioning

  ZONENAME=$(mdata sdc:zonename)
  HOSTNAME=$(mdata sdc:hostname || echo "${ZONENAME}.$(mdata sdc:dns_domain)")
  RESOLVERS=$(mdata sdc:resolvers || echo "8.8.8.8 8.8.4.4")

  RAM_IN_BYTES=$(echo "$(mdata sdc:max_physical_memory)*1024^2" | bc 2>/dev/null)
  SWAP_IN_BYTES=$(echo "$(mdata sdc:max_swap)*1024^2" | bc 2>/dev/null)
  TMPFS=$(mdata sdc:tmpfs || echo "$((RAM_IN_BYTES/1024/1024))")m

  while : ${i:=-1}; ((i++)); IFACE=$(mdata sdc:nics.${i}.interface); [ ${IFACE} ]; do
    NET_INTERFACES=(${NET_INTERFACES[@]} ${IFACE})
    THIS_IP=$(mdata sdc:nics.${i}.ip)
    # only use valid IPs
    [[ "${THIS_IP}." =~ ^(([01]?[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.){4}$ ]] || continue
    eval "${IFACE}_IP=${THIS_IP}"
    case "$(mdata sdc:nics.${i}.nic_tag)" in
      external)
        PUBLIC_IPS=(${PUBLIC_IPS[@]} ${THIS_IP})
        ;;
      *)
        PRIVATE_IPS=(${PRIVATE_IPS[@]} ${THIS_IP})
        ;;
    esac
  done

  # Pick a valid IP for either of the public/private vars, fall back to localhost
  PUBLIC_IP=${PUBLIC_IPS[0]-${PRIVATE_IPS[0]-127.0.0.1}}
  PRIVATE_IP=${PRIVATE_IPS[0]-${PUBLIC_IPS[0]-127.0.0.1}}
  
else

  # This seems to be an older release of SmartOS, or SDC 6.5.x
  # We cannot source the information we need from metadata, so
  # need the 'zoneconfig' file passed with some information.

  if [ -f "${ZONECONFIG}" ]; then
    source ${ZONECONFIG}
  fi

  : ${ZONENAME:=$(zonename)}
  : ${HOSTNAME:=${ZONENAME}.local}
  : ${RESOLVERS:=8.8.8.8 8.8.4.4}

  [ ${RAM_IN_BYTES} ] || RAM_IN_BYTES=$( kstat -p -c zone_memory_cap -s physcap | awk '{print $2}' )
  [ ${RAM_IN_BYTES} -gt 0 2>/dev/null ] || RAM_IN_BYTES=134217728
  log "zone physical memory cap determined as $((RAM_IN_BYTES/1024/1024)) MiB"

  [ ${SWAP_IN_BYTES} ] || SWAP_IN_BYTES=$( kstat -p -c zone_memory_cap -s swapcap | awk '{print $2}' )
  [ ${SWAP_IN_BYTES} -gt 0 2>/dev/null ] || SWAP_IN_BYTES=$((RAM_IN_BYTES*2))
  log "zone virtual memory cap determined as $((SWAP_IN_BYTES/1024/1024)) MiB"

  [ ${TMPFS} ] || TMPFS=$((RAM_IN_BYTES/1024/1024))m

  while : ${i:=-1}; ((i++)); IFACE=NET${i}_INTERFACE; [ ${!IFACE} ]; do
    NET_INTERFACES=(${NET_INTERFACES[@]} ${!IFACE})
    eval "${!IFACE}_IP=\${NET${i}_IP}"
  done

  # We should already have PUBLIC_IP & PRIVATE_IP set via zoneconfig

  PUBLIC_IPS=(${PUBLIC_IP})
  PRIVATE_IPS=(${PRIVATE_IP})

fi

# Use mdata-get to retrieve passwords for users needed by the image
# put them in respective variables (e.g. for 'admin' use $ADMIN_PW)
# This works on 1st gen metadata platforms too (SDC 6.5.x).

: ${USERS=admin root}
USERS=(${USERS})

for USER in ${USERS[@]}; do
  PASS_VAR_LOWER=${USER}_pw
  PASS_VAR_UPPER=$(echo ${PASS_VAR_LOWER} | tr '[a-z]' '[A-Z]')

  if [ ${HAS_METADATA} ]; then
    USER_PW="$(mdata ${PASS_VAR_LOWER})" || unset USER_PW
    if [ -n "${USER_PW}" ]; then
      eval "${PASS_VAR_UPPER}='${USER_PW}'"
    else
      unset ${PASS_VAR_UPPER}
    fi
  fi
done

