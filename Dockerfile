#use latest armv7hf compatible debian version from group resin.io as base image
FROM resin/armv7hf-debian:stretch

#enable building ARM container on x86 machinery on the web (comment out next line if not built as automated build on docker hub) 
RUN [ "cross-build-start" ]

#labeling
LABEL maintainer="netpi@hilscher.com" \
      version="V0.9.3" \
      description="netX based TCP/IP network interface"

#version
ENV HILSCHERNETPI_NETX_TCPIP_NETWORK_INTERFACE_VERSION 0.9.3

#copy files
COPY ./init.d/ /etc/init.d/ 
COPY ./driver/ ./firmware/ /tmp/

#do installation
RUN apt-get update  \
    && apt-get install -y openssh-server build-essential network-manager ifupdown \
    && dpkg -i /tmp/netx-docker-pi-drv-1.1.3.deb \
    && dpkg -i /tmp/netx-docker-pi-pns-eth-3.12.0.8.deb \
    && gcc /tmp/cifx0daemon.c -o /opt/cifx/cifx0daemon -I/usr/include/cifx -Iincludes/ -lcifx -pthread \
    && sudo sed -i 's/^managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf \
    && cp /tmp/cifx0 /etc/network/interfaces.d \
    && rm -rf /tmp/* \
    && apt-get remove build-essential \
    && apt-get -yqq autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

#set the entrypoint
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if not built as automated build on docker hub)
RUN [ "cross-build-end" ]
