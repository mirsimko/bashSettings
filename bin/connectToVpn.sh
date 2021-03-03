#!/bin/bash

whereTo=${1:-"is-us-01"}

# echo ${#whereTo}
# echo ${whereTo: -3}

directory="$HOME/MEGAsync/ProtonVPN_securecore_configs/"
endFile=""
if [ "$whereTo" == "fjfi" ] || [ "$whereTo" == "CVUT" ] ; then
  sudo vpnc CVUT.conf
  exit 0
elif [ "$whereTo" == "iolabs" ]; then
  endFile=.ovpn
elif [ ${#whereTo} == "2" ] || [ "${whereTo: -3}" == "-01" ] ; then
  endFile=".protonvpn.com.udp1194.ovpn"
else
  endFile="-01.protonvpn.com.udp1194.ovpn"
fi

sudo openvpn "$directory$whereTo$endFile"

# echo Downloaded configuration files are:
# ls "$directory" | grep "$endFile"
