# znapzend-docker-proxmox
A container for running znapzend based on proxmox VE so the ZFS tools in the container match the host proxmox system.

This is a container for running znapzend (https://github.com/oetiker/znapzend) with a container based on proxmox VE. This is to assure that the ZFS version used by znapzend matches the ZFS module version installed in proxmox when running znapzend as a container on proxmox.

There are multiple versions of this container based on the proxmox VE version and the ZFS utilities version so you can choose the same version installed in your proxmox installation. You should update the container version used if you update the zfs kernel module / utilities in your proxmox installation.

You can see the details on how to use znapzend in the official readme on github here: https://github.com/oetiker/znapzend

---

**NOTE:** To override the command (e.g., to send options to znapzend), you must send the options and znapzend command as one string since the entrypoint is a bash shell. And, you must pass `--logto=/dev/stdout` if you want logs to still show up in the docker logs for the container.

E.g.,

Docker compose:
```
version: '3'

services:
  znapzend:
    image: stuckj/znapzend-proxmox:pve-8.x-zfs-latest
    privileged: true
    devices:
      - /dev/zfs:/dev/zfs
    restart: unless-stopped
   volumes:
      - /root/.ssh:/root/.ssh
    command: [ "znapzend --logto=/dev/stdout --autoCreation" ]
```

Docker CLI:
```
docker run -it stuckj/znapzend-proxmox:pve-8.x-zfs-latest "znapzend --logto=/dev/stdout --autoCreation"
```
