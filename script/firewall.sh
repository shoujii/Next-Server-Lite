#!/bin/bash

install_firewall() {

trap error_exit ERR

if [ $(dpkg-query -l | grep ipset | wc -l) -ne 1 ]; then
   install_packages "ipset"
fi

git clone https://github.com/arno-iptables-firewall/aif.git /root/NeXt-Server-Lite/sources/aif -q

cd /root/NeXt-Server-Lite/sources/aif

mkdir -p /usr/local/share/arno-iptables-firewall/plugins
mkdir -p /usr/local/share/man/{man1,man8}
mkdir -p /usr/local/share/doc/arno-iptables-firewall
mkdir -p /etc/arno-iptables-firewall/{plugins,conf.d}

cp bin/arno-iptables-firewall /usr/local/sbin/
cp bin/arno-fwfilter /usr/local/bin/
cp -R share/arno-iptables-firewall/* /usr/local/share/arno-iptables-firewall/

ln -s /usr/local/share/arno-iptables-firewall/plugins/traffic-accounting-show /usr/local/sbin/traffic-accounting-show

gzip -c share/man/man1/arno-fwfilter.1 >/usr/local/share/man/man1/arno-fwfilter.1.gz 
gzip -c share/man/man8/arno-iptables-firewall.8 >/usr/local/share/man/man8/arno-iptables-firewall.8.gz 

cp README /usr/local/share/doc/arno-iptables-firewall/
cp etc/init.d/arno-iptables-firewall /etc/init.d/
if [ -d "/usr/lib/systemd/system/" ]; then
  cp lib/systemd/system/arno-iptables-firewall.service /usr/lib/systemd/system/
fi

cp etc/arno-iptables-firewall/firewall.conf /etc/arno-iptables-firewall/
cp etc/arno-iptables-firewall/custom-rules /etc/arno-iptables-firewall/
cp -R etc/arno-iptables-firewall/plugins/ /etc/arno-iptables-firewall/
cp share/arno-iptables-firewall/environment /usr/local/share/

chmod +x /usr/local/sbin/arno-iptables-firewall
chown 0:0 /etc/arno-iptables-firewall/firewall.conf
chown 0:0 /etc/arno-iptables-firewall/custom-rules
chmod +x /usr/local/share/environment

# Start Arno-Iptables-Firewall at boot
update-rc.d -f arno-iptables-firewall start 11 S . stop 10 0 6 

# Configure firewall.conf
bash /usr/local/share/environment 

INTERFACE=$(ip route get 9.9.9.9 | head -1 | cut -d' ' -f5)

sed_replace_word "^EXT_IF=.*" "EXT_IF=\"${INTERFACE}"\" "/etc/arno-iptables-firewall/firewall.conf"

if [[ ${USE_MAILSERVER} == '1' ]]; then
   sed_replace_word "^OPEN_TCP=.*" "OPEN_TCP=\"${SSH_PORT}, 25, 80, 110, 143, 443, 465, 587, 993, 995, 4000"\" "/etc/arno-iptables-firewall/firewall.conf"
else
   sed_replace_word "^OPEN_TCP=.*" "OPEN_TCP=\"${SSH_PORT}, 80, 443, 4000"\" "/etc/arno-iptables-firewall/firewall.conf"
fi

sed_replace_word "^VERBOSE=.*" "VERBOSE=\"1"\" "/etc/init.d/arno-iptables-firewall"

systemctl -q daemon-reload
systemctl -q start arno-iptables-firewall.service

#Fix error with /etc/rc.local
touch /etc/rc.local

mkdir -p /root/NeXt-Server-Lite/sources/blacklist
mkdir -p /etc/arno-iptables-firewall/blocklists

cat > /etc/cron.daily/blocked-hosts <<END
#!/bin/bash
BLACKLIST_DIR="/root/NeXt-Server-Lite/sources/blacklist"
BLACKLIST="/etc/arno-iptables-firewall/blocklists/blocklist.netset"
BLACKLIST_TEMP="\$BLACKLIST_DIR/blacklist"
LIST=(
"https://www.projecthoneypot.org/list_of_ips.php?t=d&rss=1"
"https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=1.1.1.1"
"https://www.maxmind.com/en/high-risk-ip-sample-list"
"https://danger.rulez.sk/projects/bruteforceblocker/blist.php"
"https://rules.emergingthreats.net/blockrules/compromised-ips.txt"
"https://www.spamhaus.org/drop/drop.lasso"
"http://cinsscore.com/list/ci-badguys.txt"
"https://www.openbl.org/lists/base.txt"
"https://www.autoshun.org/files/shunlist.csv"
"https://lists.blocklist.de/lists/all.txt"
"https://blocklist.greensnow.co/greensnow.txt"
"https://www.stopforumspam.com/downloads/toxic_ip_cidr.txt"
"https://myip.ms/files/blacklist/csf/latest_blacklist.txt"
"https://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt"
"https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt"
)
for i in "\${LIST[@]}"
do
    wget -T 10 -t 2 --no-check-certificate -O - \$i | grep -Po '(?:\d{1,3}\.){3}\d{1,3}(?:/\d{1,2})?' >> \$BLACKLIST_TEMP
done
sort \$BLACKLIST_TEMP -n | uniq > \$BLACKLIST
cp \$BLACKLIST_TEMP \${BLACKLIST_DIR}/blacklist\_\$(date '+%d.%m.%Y_%T' | tr -d :) && rm \$BLACKLIST_TEMP
/etc/init.d/arno-iptables-firewall force-reload
END
chmod +x /etc/cron.daily/blocked-hosts

systemctl -q restart {nginx,php$PHPVERSION8-fpm}
}