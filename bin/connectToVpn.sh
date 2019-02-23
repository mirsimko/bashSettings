#!/bin/bash

whereTo=${1:-"se-fr-01"}

directory="/home/miro/MEGAsync/ProtonVPN_securecore_configs/"
endFile=""
if [ "$whereTo" == "fjfi" ] ; then
  endFile=.ovpn
elif [ "${#whereTo}" == 4 || "${whereTo:-3}" == "-01" ] ; then
  endFile=".protonvpn.com.udp1194.ovpn"
else
  endFile=".protonvpn.com.udp1194.ovpn"
fi

sudo openvpn "$directory$whereTo$endFile"

# echo Downloaded configuration files are:
# ls "$directory" | grep "$endFile"
