log "setting system passwords for users"

ADMIN_PW=$(mdata-get admin_pw 2>/dev/null) || unset ADMIN_PW

if [ "${ADMIN_PW}" ] && \
   [ -e "$(type -p genbfpw)" ] && [ -e "$(type -p changepass)" ]; then
  if [[ ! "${ADMIN_PW}" =~ ^\$2a\$ ]]; then
    # Need to get a Blowfish hash first
    ADMIN_PW=$(genbfpw -p ${ADMIN_PW})
  fi
  echo "admin:${ADMIN_PW}" | changepass -e > /dev/null 2>&1 || \
    error "System 'admin' password change failed."
else
  passwd -N admin
fi

ROOT_PW=$(mdata-get root_pw 2>/dev/null) || unset ROOT_PW

if [ "${ROOT_PW}" ] && \
   [ -e "$(type -p genbfpw)" ] && [ -e "$(type -p changepass)" ]; then
  if [[ ! "${ROOT_PW}" =~ ^\$2a\$ ]]; then
    # Need to get a Blowfish hash first
    ROOT_PW=$(genbfpw -p ${ROOT_PW})
  fi
  echo "root:${ROOT_PW}" | changepass -e > /dev/null 2>&1 || \
    error "System 'root' password change failed."
else
  passwd -N root
fi
