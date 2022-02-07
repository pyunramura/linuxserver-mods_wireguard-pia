#!/bin/bash

# This script is run once a port has been successfully forwarded
# The port number is passed as the first argument

[[ "$FIREWALL" == false ]] || FIREWALL=true

if [[ $FIREWALL == true ]]; then
  iptables -A INPUT -p tcp -i wg0 --dport "$1" -j ACCEPT
  iptables -A INPUT -p udp -i wg0 --dport "$1" -j ACCEPT
  echo "$(date): Allowing incoming traffic on port $1"
fi

# Set env var PF_DEST_IP to forward on to another address
# eg PF_DEST_IP=192.168.1.48
if [ -n "$PF_DEST_IP" ] && [ -n "$FWD_IFACE" ]; then
  iptables -t nat -A PREROUTING -p tcp --dport "$1" -j DNAT --to-destination "$PF_DEST_IP:$1"
  iptables -t nat -A PREROUTING -p udp --dport "$1" -j DNAT --to-destination "$PF_DEST_IP:$1"
  iptables -A FORWARD -i wg0 -o "$FWD_IFACE" -p tcp -d "$PF_DEST_IP" --dport "$1" -j ACCEPT
  iptables -A FORWARD -i wg0 -o "$FWD_IFACE" -p udp -d "$PF_DEST_IP" --dport "$1" -j ACCEPT
  echo "$(date): Forwarding incoming VPN traffic on port $1 to $PF_DEST_IP:$1"
fi

update_script=/config/wireguard/scripts/port-update.sh

# Run another user-defined script if defined and present
[[ "$PORT_SCRIPT" == true ]] && [ -x "$update_script" ] && echo "$(date): Running user-defined script: $update_script" && eval "$update_script $1" &
