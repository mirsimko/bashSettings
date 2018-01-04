#!/bin/bash

whereTo=${1:-"se-fr"}

directory="/home/miro/MEGAsync/ProtonVPN_securecore_configs/"
endFile="-01.protonvpn.com.udp1194.ovpn"

sudo openvpn "$directory$whereTo$endFile"
