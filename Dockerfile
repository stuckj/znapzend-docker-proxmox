
##### Builder image
ARG DEBIAN_VERSION=buster
FROM docker.io/library/debian:${DEBIAN_VERSION} as builder

RUN \
  apt update && apt install -y \
  curl \
  autoconf \
  automake \
  make \
  perl \
  git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

RUN \
  git clone https://github.com/oetiker/znapzend.git .

RUN \
  ./bootstrap.sh && \
  ./configure --prefix=/opt/znapzend && \
  make && \
  make install

##### Runtime image
FROM docker.io/library/debian:${DEBIAN_VERSION} as runtime
ARG DEBIAN_VERSION=buster
#ARG ZFSUTILS_VERSION=0.8.5-pve1
ARG ZFSUTILS_VERSION
ARG PROXMOX_GPG_FILE=proxmox-ve-release-6.x.gpg
#ARG PROXMOX_GPG_FILE=proxmox-release-${DEBIAN_VERSION}.gpg
ARG PROXMOX_GPG_URL=http://download.proxmox.com/debian/${PROXMOX_GPG_FILE}

# Add the debian contrib repos. Needed for zfs.
RUN \
  mv /etc/apt/sources.list /etc/apt/sources.list.bak \
  && cat /etc/apt/sources.list.bak | sed -e "s/main$/main contrib/" > /etc/apt/sources.list

RUN \
  # Install the proxmox repo keys...
  apt update && apt install -y \
  wget \
  gnupg \
  && wget http://download.proxmox.com/debian/key.asc \
  && apt-key add key.asc \
  && rm key.asc \
  && echo ${PROXMOX_GPG_URL} --- ${PROXMOX_GPG_FILE} \
  && wget ${PROXMOX_GPG_URL} \
  && mv ${PROXMOX_GPG_FILE} /etc/apt/trusted.gpg.d \
  # Add the proxmox repo.
  && echo "deb http://download.proxmox.com/debian/pve ${DEBIAN_VERSION} pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list \
  # Then install everything we need to run the container.
  && apt update && apt install -y \
  $([ -z ${ZFSUTILS_VERSION} ] && echo "zfsutils-linux" || echo "zfsutils-linux=${ZFSUTILS_VERSION}") \
  nano \
  vim \
  perl \
  ssh \
  mbuffer \
  # Cleanup.
  && rm -rf /var/lib/apt/lists/*

RUN \
  ln -s /dev/stdout /var/log/syslog

COPY --from=builder /opt/znapzend/ /opt/znapzend

RUN \
  ln -s /opt/znapzend/bin/znapzend /usr/bin/znapzend && \
  ln -s /opt/znapzend/bin/znapzendzetup /usr/bin/znapzendzetup && \
  ln -s /opt/znapzend/bin/znapzendztatz /usr/bin/znapzendztatz

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ "znapzend --logto=/dev/stdout" ]

##### Tests
#FROM builder as test
#
#RUN \
#  ./test.sh
