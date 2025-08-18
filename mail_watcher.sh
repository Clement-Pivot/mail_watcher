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
		echo "`date` Ordre : $o" >> /var/log/mail_watcher
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
			echo "`date` Status du nas." >> /var/log/mail_watcher
			rep="<h2>CPU Temp : `sensors | grep CPUTIN | awk '{print $2}'`</h2>
<h2>TOP : </h2>
<pre>`top -b -n 1 | head -n 5`</pre>
<h2>Users :</h2>
<pre>`who`</pre>
<h2>Top CPU : </h2>
<pre>`ps aux --sort -%cpu | head -n 15`</pre>
<h2>Top RAM : </h2>
<pre>`ps aux --sort -%mem | head -n 15`</pre>
<h2>Disk usage : </h2>
<pre>`iotop -a -b -n 1 | head -n 15`</pre>
<pre>`iostat | tail -n 5`</pre>
<h2>Disk space : </h2>
<pre>`df -h`</pre>
<h2>Disk SMART :</h2>
<pre>/dev/sda : `smartctl -l selftest /dev/sda | grep '# 1'`
/dev/sdb : `smartctl -l selftest /dev/sdb | grep '# 1'`
/dev/sdc : `smartctl -l selftest /dev/sdc | grep '# 1'`
</pre>
<h2>ZPOOL status :</h2>			
<pre>`zpool status`</pre>
<h2>APT state : </h2>			
<pre>`apt update | tail -n 1`</pre>
<h2>Net bandwith now : </h2>	
<pre>`ifstat -t -T 1 1`</pre>
<h2>Connections :</h2>
<pre>`netstat -tp`</pre>
<h2>Nginx :</h2>
<pre>`curl -k https://malfeitor.duckdns.org/nginx_status`</pre>
<h2>Fail2ban :</h2>
<pre>`fail2ban-client status | sed -n 's/,//g;s/.*Jail list://p' | xargs -n1 fail2ban-client status`</pre>
<h2>Mails :</h2>
`cat /root/mails && echo '' > /root/mails`
`/root/scripts/mail_translater.py /root/mails_fail2ban && echo '' > /root/mails_fail2ban`"
			printf "%s" "$rep" | mail -a "Content-Type: text/html" -s "[STATE] NAS reply at `date`" clement.pivot@protonmail.com
		else
			echo "$m" >> /root/mails
		fi
	fi
	sleep 10
done
