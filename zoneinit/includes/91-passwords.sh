: ${USERS=admin root}
USERS=(${USERS})

for USER in ${USERS[@]}; do

  log "setting system password for user '${USER}'"
  PASS_VAR_LOWER=${USER}_pw
  PASS_VAR_UPPER=$(echo ${PASS_VAR_LOWER} | tr '[a-z]' '[A-Z]')

  USER_PW=${!PASS_VAR_UPPER}
  if [ ! ${USER_PW} ] && [ ${HAS_METADATA} ]; then
    USER_PW=$(mdata-get ${PASS_VAR_LOWER} 2>/dev/null) || unset USER_PW
  fi

  if [ "${USER_PW}" ] && \
     [ -e "$(type -p genbfpw)" ] && [ -e "$(type -p changepass)" ]; then
    if [[ ! "${USER_PW}" =~ ^\$2a\$ ]]; then
      # Need to get a Blowfish hash first
      USER_PW=$(genbfpw -p ${USER_PW})
    fi
    echo "${USER}:${USER_PW}" | changepass -e > /dev/null 2>&1 || \
      error "System password change for '${USER}' failed."
  else
    passwd -N ${USER}
  fi
done
