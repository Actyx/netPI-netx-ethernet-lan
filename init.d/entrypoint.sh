#!/bin/bash +e
# catch signals as PID 1 in a container

IP=${NETX_IP:-172.168.42.11}

# SIGNAL-handler
term_handler() {

  echo "terminating ssh ..."
  /etc/init.d/ssh stop

  exit 143; # 128 + 15 -- SIGTERM
}

# on callback, stop all started processes in term_handler
trap 'kill ${!}; term_handler' SIGINT SIGKILL SIGTERM SIGQUIT SIGTSTP SIGSTOP SIGHUP

# run applications in the background
echo "starting ssh ..."
/etc/init.d/ssh start

# create netx "cifx0" ethernet network interface 
/opt/cifx/cifx0daemon

sleep 2
#Set default IP, as it's currently not possible to manage this network device via NetworkManager
#https://forums.resin.io/t/tun-device-unmanaged-by-networkmanager/2801/8
ip link set cifx0 up
ip addr add $IP dev cifx0

# wait forever not to exit the container
while true
do
  tail -f /dev/null & wait ${!}
done

exit 0
