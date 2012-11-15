for _HASHTOOL in /usr/lib/cryptpass $(type -p genbfpw); do
  if [ -x ${_HASHTOOL} ]; then
    HASHTOOL=${_HASHTOOL/genbfpw/genbfpw -p}
    break
  fi
done

for _PASSTOOL in $(type -p changepass); do
  if [ -x ${_PASSTOOL} ]; then
    PASSTOOL=${_PASSTOOL}
    break
  fi
done

for USER in ${USERS[@]}; do

  log "setting system password for user '${USER}'"
  PASS_VAR_LOWER=${USER}_pw
  PASS_VAR_UPPER=$(echo ${PASS_VAR_LOWER} | tr '[a-z]' '[A-Z]')
  USER_PW="${!PASS_VAR_UPPER}"

  if [ "${USER_PW}" ] && [ "${HASHTOOL}" ] && [ "${PASSTOOL}" ]; then

    # Make sure it's blowfish-hashed
    [[ "${USER_PW}" =~ ^\$2a\$ ]] || USER_PW=$(${HASHTOOL} "${USER_PW}")

    if echo "${USER}:${USER_PW}" | changepass -e > /dev/null 2>&1; then
      SSH_ALLOW_PASSWORDS=true
    else
      log "system password change for '${USER}' failed"
      passwd -N ${USER} >/dev/null
    fi
  else
    passwd -N ${USER} >/dev/null
  fi
done
