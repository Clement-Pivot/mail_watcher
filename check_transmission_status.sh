#!/bin/bash

state="$(docker container ls --format 'table {{.Status}}\t{{.Image}}' | grep transmission | awk '{print $1}')"

if [[ "$state" != "Up" ]] && [[ ! -f /tmp/transmission_vpn_down ]]; then
    echo "Transmission Down $(date)"
    touch /tmp/transmission_vpn_down
    printf "%s" "Transmission VPN down, reply vpnbook password with subject [OPENVPN] at <a href='mailto:root@lanrumble.com'>root@lanrumble.com</a>" | mail -a "Content-Type: text/html" -s "[OPENVPN] Down at `date`" clement.pivot@protonmail.com
fi

#pwd_url="password.php?t=202508191024&bg=undefined"

#curl -s -X POST --header "apikey: 5a64d478-9c89-43d8-88e3-c65de9999580" \
#    -F "url=https://www.vpnbook.com/${pwd_url}" \
#    -F 'language=eng' \
#    -F 'isOverlayRequired=true' \
#    -F 'FileType=.Auto' \
#    -F 'IsCreateSearchablePDF=false' \
#    -F 'isSearchablePdfHideTextLayer=true' \
#    -F 'scale=true' \
#    -F 'detectOrientation=false' \
#    -F 'isTable=false' \
#    "https://api.ocr.space/parse/image" -o /tmp/vpnbook_pwd