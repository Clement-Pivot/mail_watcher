#!/bin/bash

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
<pre>`curl -k https://lanrumble.com/nginx_status`</pre>
<h2>Fail2ban :</h2>
<pre>`fail2ban-client status | sed -n 's/,//g;s/.*Jail list://p' | xargs -n1 fail2ban-client status`</pre>
<h2>Mails :</h2>
`cat /root/mails && echo '' > /root/mails`
`./mail_translater.py /root/mails_fail2ban && echo '' > /root/mails_fail2ban`"

printf "%s" "$rep" | mail -a "Content-Type: text/html" -s "[STATE] NAS reply at `date`" clement.pivot@protonmail.com