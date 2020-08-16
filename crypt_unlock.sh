#!/bin/sh
# /usr/share/initramfs-tools/hooks/crypt_unlock.sh
# Changes made to follow https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/Debian%20Buster%20Root%20on%20ZFS.html#step-5-grub-installation

PREREQ="dropbear"

prereqs() {
  echo "$PREREQ"
}


case "$1" in
  prereqs)
    prereqs
    exit 0
  ;;
esac

. "${CONFDIR}/initramfs.conf" 
. /usr/share/initramfs-tools/hook-functions

if [ "${DROPBEAR}" != "n" ] && [ -r "/etc/zfs" ] ; then
cat > "${DESTDIR}/bin/unlock" << EOF 
#!/bin/sh 
if PATH=/lib/unlock:/bin:/sbin /scripts/local-top/cryptroot; then 
kill `ps | grep zfs | grep -v "grep" | awk '{print $1}'` 
/sbin/zfs load-key -a
# rpool
# your zpool name and root zfs name and the mountpoint
mount -o zfsutil -t zfs rpool /
kill `ps | grep zfs | grep -v "grep" | awk '{print $1}'` 
exit 0 
fi 
exit 1 
EOF

chmod 755 "${DESTDIR}/bin/unlock"
mkdir -p "${DESTDIR}/lib/unlock"

cat > "${DESTDIR}/lib/unlock/plymouth" << EOF 
#!/bin/sh
[ "$1" == "--ping" ] && exit 1
/bin/plymouth "$@" 
EOF

chmod 755 "${DESTDIR}/lib/unlock/plymouth"
echo To unlock root-partition run "unlock" >> ${DESTDIR}/etc/motd
fi
