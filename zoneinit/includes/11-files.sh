log "cleaning files"

cp /dev/null /var/log/auth.log >/dev/null

log "substituting placeholders for real data in config files"

substitute_files=($(find /etc /opt/local/etc -type f | sort | xargs \
  /usr/bin/egrep -l '@(PUBLIC_IP|PRIVATE_IP|HOSTNAME|ZONENAME)@' || true))

for file in ${substitute_files[@]}; do
  if sed -e "s/@PUBLIC_IP@/${PUBLIC_IP}/g" -e "s/@PRIVATE_IP@/${PRIVATE_IP}/g" \
         -e "s/@HOSTNAME@/${HOSTNAME}/g" -e "s/@ZONENAME@/${ZONENAME}/g" \
         ${file} > ${file}.tmp; then
    mv ${file}{.tmp,}
  fi
  rm -f ${file}.tmp
done

if sed -e "/tmpfs/s/-$/size=${TMPFS}/" /etc/vfstab > /etc/vfstab.tmp 2>/dev/null; then
  mv /etc/vfstab{.tmp,}
fi
rm -f /etc/vfstab.tmp
