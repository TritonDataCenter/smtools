log "generating a new pair of SSH keys"

rm -f /etc/ssh/ssh_host_*
/lib/svc/method/sshd -c >/dev/null || \
  error "SSH key refresh failed."

if [ ${SSH_ALLOW_PASSWORDS} ]; then
  log "enabling password authentication in SSH"
  sed -ri'' '/^PasswordAuthentication/s/[a-zA-Z]+$/yes/' \
    /etc/ssh/sshd_config
fi
