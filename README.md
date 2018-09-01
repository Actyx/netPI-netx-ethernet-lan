## Ethernet across Industrial Ethernet ports 

## Environment variables

* `NETX_IP`: Static IP address for the `cifx0` interface, defaults to `172.168.42.11`.

Made for [netPI RTE 3](https://www.netiot.com/netpi/), the Open Edge Connectivity Ecosystem with Industrial Ethernet support

### Using netPI's Industrial Ethernet network ports as standard Ethernet interface

The image provided hereunder deploys a container with installed software turning netPI's Industrial Ethernet ports into a two-ported switched standard Ethernet network interface with a single IP address.

Base of this image builds a tagged version of [debian:stretch](https://hub.docker.com/r/resin/armv7hf-debian/tags/) with enabled [SSH](https://en.wikipedia.org/wiki/Secure_Shell), created user 'root', installed netX driver, network interface daemon and standard Ethernet supporting netX firmware creating an additional network interface named `cifx0`(**c**ommunication **i**nter**f**ace **x**).  The interface can be administered with standard commands such as [ip](https://linux.die.net/man/8/ip) or similar.

#### Container prerequisites

##### Port mapping

For enabling remote login to the container across SSH the container's SSH port 22 needs to be exposed to the host.

##### Privileged mode

The container creates an Ethernet network interface (LAN) from netPI's Industrial network controller netX. Creating a LAN needs full access to the Docker host. Only the privileged mode option lifts the enforced container limitations to allow creation of such a network interface.

##### Host devices

To grant access to the netX from inside the container the `/dev/spidev0.0` host device needs to be exposed to the container.

To allow the container creating an additional network device for the netX network controller the `/dev/net/tun` host device needs to be expose to the container.

#### Limitation

The `cifx0` interface does not support Ethernet package reception of type multicast.

Servicing the `cifx0` interface is only possible in the container it was created. It is not available to the Docker host or to any other containers started.

Since netX network controller is a single resource a `cifx0` interface can only be created once at a time on netPI.

#### Driver, Firmware and Daemon

There are three components necessary to get the `cifx0` recognized as Ethernet interface by the NetworkManager and the networking server.

##### Driver

There is the netX driver in the repository's folder `driver` negotiating the communication between the Raspberry CPU and netX. The driver is installed using the command `dpkg -i netx-docker-pi-drv-x.x.x.deb` and comes preinstalled in the container. The driver communicates across the device `/dev/spidev0.0` with netX.

##### Firmware

There is the firmware for netX in the repository's folder `firmware` enabling the netX Ethernet LAN function. The firmware is installed using the command `dpkg -i netx-docker-pi-pns-eth-x.x.x.x.deb` and comes preinstalled in the container. Once an application (Daemon) is starting the driver, the driver checks whether or not netX is loaded with the appropriate firmware. If not the driver then loads the firmware automatically into netX and starts it.

##### Daemon

There is the Deamon in the repository's folder `driver` running as a background process and keeping the `cifx0` Ethernet interface active. The Daemon is available in the repository as source code named `cifx0daemon.c` and comes precompiled in the container at `/opt/cifx0/cifx0daemon` by using the gcc compiler with the option `-pthread` since it uses thread child/parent forking. 

The container starts the Daemon by its entrypoint script `/etc/init.d/entrypoint.sh`. You can see the Daemon running using the `ps -e` command as `cifx0daemon` process.

If you kill the `cifx0daemon` process the `cifx0` interface will be removed as well. The Daemon can be restarted at any time using the `/opt/cifx0/cifx0daemon` command.
