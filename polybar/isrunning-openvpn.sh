#!/bin/sh

if [ "$(pgrep openvpn)" ]; then
    echo "VPN connected"
else
    echo "VPN offline"
fi