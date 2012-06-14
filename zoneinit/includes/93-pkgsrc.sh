log "updating pkgsrc repository URL"

if [ -n "${PKGSRC_URL}" ]; then
  if [[ "${PKGSRC_URL}" =~ :// ]]; then
    # is a full URL, take it as is and don't mess with subdirs
    PKGSRC_REPO=${PKGSRC_URL}
  else
    # is just a hostname, so take the release and add it up
    PKGSRC_RELEASE=$(cat ${BASE}/zoneinit.d/pkgsrc_release)
    PKGSRC_REPO=http://${PKGSRC_URL}/${PKGSRC_RELEASE}/All
  fi
  echo "PKG_PATH=${PKGSRC_REPO}" > /opt/local/etc/pkg_install.conf
  echo "${PKGSRC_REPO}" > /opt/local/etc/pkgin/repositories.conf
fi

if [ "${NETWORKING}" == "yes" ]; then
  log "updating pkgin database"
  pkgin -f -y update >/dev/null || true
fi
