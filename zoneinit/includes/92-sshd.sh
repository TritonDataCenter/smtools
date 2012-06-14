log "generating a new pair of SSH keys"

rm -f /etc/ssh/ssh_host_*
/lib/svc/method/sshd -c >/dev/null || \
  error "SSH key refresh failed."

if [ ${ADMIN_PW} ] || [ ${ROOT_PW} ]; then
  log "enabling password authentication in SSH"
  sed -ri'' '/^PasswordAuthentication/s/[a-zA-Z]+$/yes/' \
    /etc/ssh/sshd_config
fi
