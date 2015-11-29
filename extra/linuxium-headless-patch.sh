#!/bin/sh

# Linuxium's script for running Ubuntu headless

EUID=`id -u`
if [ ${EUID} -ne 0 ]; then
	echo
	echo "$0: Run this script as root ... exiting."
	echo
	exit
fi

if [ -f /boot/grub/grub.cfg.orig ]; then
	echo
	echo "$0: Pre-existing /boot/grub/grub.cfg.orig found ... exiting."
	echo
	exit
else
	echo
	echo "$0: Saving /boot/grub/grub.cfg as /boot/grub/grub.cfg.orig ... "
	mv /boot/grub/grub.cfg /boot/grub/grub.cfg.orig
fi

ROOT_UUID=`awk '{print $2}' /proc/cmdline`
UUID=`echo ${ROOT_UUID} | sed 's/root=UUID=//'`
LINUX=`grep -C 2 ${ROOT_UUID} /boot/grub/grub.cfg.orig | head -4 | tail -2 | head -1 | awk '{print $2}'`
INITRD=`grep -C 2 ${ROOT_UUID} /boot/grub/grub.cfg.orig | head -4 | tail -1 | awk '{print $2}'`
PARAMETERS_STRING=`grep -C 2 ${ROOT_UUID} /boot/grub/grub.cfg.orig | head -4 | tail -2 | head -1 | sed 's/linux//' | sed "s?${LINUX}??" | sed "s?${ROOT_UUID}??" | sed 's/quiet//' | sed 's/splash//' | sed 's/$vt_handoff//'`
PARAMETERS=`echo $PARAMETERS_STRING | tr -s " "`

echo "$0: Patching /boot/grub/grub.cfg ... "
cat > /boot/grub/grub.cfg <<+
#
# DO NOT EDIT THIS FILE
#
# It is automatically generated by linuxium-headless-patch.sh
#

set default="0"
set timeout=0

menuentry 'Ubuntu' --class ubuntu --class gnu-linux --class gnu --class os {
	insmod gzio
	insmod part_gpt
	insmod ext2
	search --no-floppy --fs-uuid --set=root ${UUID}
	linux	${LINUX} ${ROOT_UUID} ${PARAMETERS} text
	initrd	${INITRD}
}
+
echo "$0: Successfully patched ... now reboot."
echo