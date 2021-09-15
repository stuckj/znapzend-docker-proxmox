#!/bin/bash

# PVE 6.x...
PVE_VERSION=6.x
DEBIAN_VERSION=buster
PROXMOX_GPG_FILE=proxmox-ve-release-6.x.gpg

# Derived from this on a proxmox host: apt-cache madison zfsutils-linux | awk '{print $3}'
ZFSUTILS_VERSIONS=("0.7.12-2+deb10u2" "0.8.1-pve1" "0.8.1-pve2" "0.8.2-pve1" "0.8.2-pve2" "0.8.3-pve1" "0.8.4-pve1" "0.8.4-pve2" "0.8.5-pve1" "2.0.1-pve1" "2.0.3-pve1" "2.0.3-pve2" "2.0.4-pve1" "2.0.5-pve1~bpo10+1" "latest")

for ZFSUTILS_VERSION in "${ZFSUTILS_VERSIONS[@]}"; do
  ZFS_VERSION_TAG="$(echo ${ZFSUTILS_VERSION} | sed -E 's/[^A-Za-z0-9._-]/-/g')"

  if [ "${ZFSUTILS_VERSION}" = "latest" ]; then
    ZFSUTILS_VERSION=
  fi

  echo "**************************************************"
  echo "***"
  echo "*** Building PVE_VERSION=${PVE_VERSION}, DEBIAN_VERSION=${DEBIAN_VERSION}, PROXMOX_GPG_FILE=${PROXMOX_GPG_FILE}, ZFSUTILS_VERSION=${ZFSUTILS_VERSION}, ZFS_VERSION_TAG=${ZFS_VERSION_TAG}"
  echo "***"
  echo "**************************************************"

  docker build -t stuckj/znapzend-proxmox:pve-${PVE_VERSION}-zfs-${ZFS_VERSION_TAG} --build-arg DEBIAN_VERSION=${DEBIAN_VERSION} --build-arg PROXMOX_GPG_FILE=${PROXMOX_GPG_FILE} --build-arg ZFSUTILS_VERSION=${ZFSUTILS_VERSION} .
done

# PVE 7.x...
# TODO: WRITE ME!!!
