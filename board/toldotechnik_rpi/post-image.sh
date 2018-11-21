#!/bin/sh

CUSTOM_BOARD_DIR="$(dirname $0)"
GENIMAGE_CFG=""
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

echo "Post-image: processing $@"

# Process custom args
for arg in "$@"
do
	case "${arg}" in
		--genimage0)
			GENIMAGE_CFG="${CUSTOM_BOARD_DIR}/genimage0.cfg"
			echo "Genimage set to genimage0.cfg"
		;;
		--genimage3)
			GENIMAGE_CFG="${CUSTOM_BOARD_DIR}/genimage3.cfg"
			echo "Genimage set to genimage3.cfg"
		;;
	esac
done

# Override cmdline.txt
cat << __EOF__ > "${BINARIES_DIR}/rpi-firmware/cmdline.txt"
console=ttyAMA0,115200 ipv6.disable=1 consoleblank=0 vt.global_cursor_default=0 logo.nologo ignore_loglevel root=/dev/mmcblk0p2 rootwait
__EOF__

# Override config.txt
cat << __EOF__ > "${BINARIES_DIR}/rpi-firmware/config.txt"
kernel=zImage
gpu_mem_256=128
gpu_mem_512=196
gpu_mem_1024=384
dtparam=audio=on
boot_delay=0
disable_splash=1
enable_uart=1
__EOF__

# Create sample url.txt
cat << __EOF__ > "${BINARIES_DIR}/url.txt"
http://localhost
__EOF__

echo "Generating SD image"
rm -rf "${GENIMAGE_TMP}"

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
        --config "${GENIMAGE_CFG}"

exit $?
