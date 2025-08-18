#!/bin/bash

echo "[STARTING] $(date)" >> /var/log/mail_watcher

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
		echo "$(date) Ordre : $o" >> /var/log/mail_watcher
		if [[ "${o^^}" == "OPENVPN" ]]; then
			t=$(echo "$m" | egrep "^[a-zA-Z0-9]{5,15}\+?\-*\+?$" | awk -F+ '{print $1}')
			echo "vpnbook" > /root/docker_openvpn_transmission/openvpn_creds
			echo "$t" >> /root/docker_openvpn_transmission/openvpn_creds
			echo "$(date) mise à jour du mot de passe Vpnbook : $t" >> /var/log/mail_watcher
		elif [[ "${o^^}" == "FAIL2BAN" ]]; then
			echo "$m" >> /root/mails_fail2ban
		elif [[ "${o^^}" == "UPGRADE" ]]; then
			apt upgrade -y &> /tmp/upgrade
			wait
			rep=$(cat /tmp/upgrade)
			printf "%s" "$rep" | mail -a "Content-Type: text/plain" -s "[UPGRADE] NAS reply at `date`" clement.pivot@protonmail.com
		elif [[ "${o^^}" == "STATE" ]]; then
			echo "Status du nas."
			echo "$(date) Status du nas." >> /var/log/mail_watcher
			./send_state.sh
		else
			echo "$m" >> /root/mails
		fi
	fi
	sleep 10
done
