# create a temporary file that disappears on the first reboot

if [[ ! -f /tmp/.FIRST_REBOOT_NOT_YET_COMPLETE ]]; then
  touch /tmp/.FIRST_REBOOT_NOT_YET_COMPLETE
fi
