#!/bin/bash

whereTo=${1:-"se-fr"}

directory="/home/miro/MEGAsync/ProtonVPN_securecore_configs/"
endFile=""
if [ "$whereTo" == "fjfi" ] ; then
  endFile=.ovpn
else
  endFile="-01.protonvpn.com.udp1194.ovpn"
fi

sudo openvpn "$directory$whereTo$endFile"

# echo Downloaded configuration files are:
# ls "$directory" | grep "$endFile"
