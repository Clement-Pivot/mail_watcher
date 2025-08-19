#!/bin/bash

logfile="/var/log/mail_watcher"

echo "[STARTING] $(date)" >> $logfile

while [ 1 ];do
	m=""
	if [[ $(echo "dec" | mail | wc -l) -gt 1 || $(echo "dec" | mail -f | wc -l) -gt 1 ]];then
		echo "Mail found !"
		if [[ $(echo "dec" | mail -f | wc -l) -gt 1 ]]; then
			m=$(echo "dec" | mail -f)
			echo "d" | mail -f
		else
			m=$(echo "dec" | mail)
			echo "d" | mail 
		fi
		o="$(echo "$m" | grep "Clement Pivot")"
		o="${o#*[}"
		length=0
		while [ $length != $(echo $o | wc -m) ];do
			length=$(echo $o | wc -m) 
			o=${o%]*}
		done
		if [[ $(echo "$o" | wc -w) -gt 1 ]];then o=$(echo $o | awk -F\  '{print $10}');fi
		echo "Ordre : $o"
		echo "$(date) Ordre : $o" >> $logfile
		if [[ "${o^^}" == "OPENVPN" ]]; then
			t=$(echo "$m" | egrep "^[a-zA-Z0-9]{5,15}\+?\-*\+?$" | awk -F+ '{print $1}')
			echo "vpnbook" > /root/docker_openvpn_transmission/openvpn_creds
			echo "$t" >> /root/docker_openvpn_transmission/openvpn_creds
			echo "$(date) mise à jour du mot de passe Vpnbook : $t" >> $logfile
			rm /tmp/transmission_vpn_down
		elif [[ "${o^^}" == "FAIL2BAN" ]]; then
			echo "$m" >> /root/mails_fail2ban
		elif [[ "${o^^}" == "UPGRADE" ]]; then
			apt upgrade -y &> /tmp/upgrade
			wait
			rep=$(cat /tmp/upgrade)
			printf "%s" "$rep" | mail -a "Content-Type: text/plain" -s "[UPGRADE] NAS reply at `date`" clement.pivot@protonmail.com
		elif [[ "${o^^}" == "STATE" ]]; then
			echo "Status du nas."
			echo "$(date) Status du nas." >> $logfile
			./send_state.sh
		else
			echo "$m" >> /root/mails
		fi
	fi
	./check_transmission_status.sh
	sleep 10
done
