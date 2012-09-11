if [ ${HAS_METADATA} ]; then
  log "enabling metadata agent"
  svcadm enable mdata:fetch
fi

# Use mdata-get to retrieve passwords for users needed by the image
# put them in respective variables (e.g. for 'admin' use $ADMIN_PW)

: ${USERS=admin root}
USERS=(${USERS})

for USER in ${USERS[@]}; do
  PASS_VAR_LOWER=${USER}_pw
  PASS_VAR_UPPER=$(echo ${PASS_VAR_LOWER} | tr '[a-z]' '[A-Z]')

  if [ ${HAS_METADATA} ]; then
    USER_PW=$(mdata-get ${PASS_VAR_LOWER} 2>/dev/null) || unset USER_PW
    if [ ${USER_PW} ]; then
      eval "${!PASS_VAR_UPPER}=${USER_PW}"
    else
      unset ${!PASS_VAR_UPPER}
    fi
  fi
done
