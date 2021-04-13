#!/bin/bash

# Get first non-loopback network device that is currently connected
GATEWAY_EUI_NIC=$(ip -oneline link show up 2>&1 | grep -v LOOPBACK | sed -E 's/^[0-9]+: ([0-9a-z]+): .*/\1/' | head -1)
if [[ -z $GATEWAY_EUI_NIC ]]; then
    echo -e "\033[91mERROR: No network interface found. Cannot set gateway ID.\033[0m"
    sleep 30
    exit 1
fi

# Then get EUI based on the MAC address of that device
GATEWAY_EUI=$(cat /sys/class/net/$GATEWAY_EUI_NIC/address | awk -F\: '{print $1$2$3"FFFE"$4$5$6}')
GATEWAY_EUI=${GATEWAY_EUI^^} # toupper
echo "Gateway EUI: $GATEWAY_EUI"

# Defaults
SERVERS=${SERVERS:-router.eu.thethings.network:1700}
GATEWAY_RESET_GPIO=${GATEWAY_RESET_GPIO:-25}
GATEWAY_EMAIL=${GATEWAY_EMAIL:-yourname@yourdomain.com}
GATEWAY_NAME=${GATEWAY_NAME:-my-gateway}
GATEWAY_LAT=${GATEWAY_LAT:-0}
GATEWAY_LON=${GATEWAY_LON:-0}
GATEWAY_ALT=${GATEWAY_ALT:-0}

# Configure LNS
CONFIG_FILE=./local_conf.json
rm -f $CONFIG_FILE
echo -ne "{\n\t\"gateway_conf\": {\n\t\t\"gateway_ID\": \"$GATEWAY_EUI\",\n\t\t\"servers\": [\n" >> $CONFIG_FILE
FIRST=true
echo $SERVERS | tr ',' '\n' | while read SERVER; do
    HOST=$(echo $SERVER | cut -s -d':' -f1)
    PORT=$(echo $SERVER | cut -s -d':' -f2)
    if [ "$PORT" != "" ]; then
        $FIRST || echo -ne ",\n"
        echo -ne "\t\t\t{ \"server_address\": \"$HOST\", \"serv_port_up\": $PORT, \"serv_port_down\": $PORT, \"serv_enabled\": true }" >> $CONFIG_FILE
        FIRST=false
    fi
done
echo -ne "\n\t\t],\n\t\t\"ref_latitude\": $GATEWAY_LAT,\n\t\t\"ref_longitude\": $GATEWAY_LON,\n\t\t\"ref_altitude\": $GATEWAY_ALT,\n\t\t\"contact_email\": \"$GATEWAY_EMAIL\",\n\t\t\"description\": \"$GATEWAY_NAME\" \n\t}\n}\n" >> $CONFIG_FILE

# Reset Concentrator
echo "$GATEWAY_RESET_GPIO"  > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$GATEWAY_RESET_GPIO/direction
echo "0"   > /sys/class/gpio/gpio$GATEWAY_RESET_GPIO/value
sleep 0.1
echo "1"   > /sys/class/gpio/gpio$GATEWAY_RESET_GPIO/value
sleep 0.1
echo "0"   > /sys/class/gpio/gpio$GATEWAY_RESET_GPIO/value
sleep 0.1
echo "$GATEWAY_RESET_GPIO"  > /sys/class/gpio/unexport

# Test the connection, wait if needed.
while [[ $(ping -c1 google.com 2>&1 | grep " 0% packet loss") == "" ]]; do
    echo -e "\033[93mWaiting for internet connection...\033[0m"
    sleep 30
    done

# Fire up the forwarder.
./poly_pkt_fwd

echo -e "\033[91mERROR: Forwarder exited, waiting 30 seconds and then rebooting service.\033[0m"
sleep 30
exit 1