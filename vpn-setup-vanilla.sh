#!/bin/bash -x

#
# drewsymo/VPN
#
# Installs a PPTP VPN-only system for CentOS
#
# @package VPN 2.0
# @since VPN 1.0
# @author Drew Morris
#

(

VPN_IP=`curl ipv4.icanhazip.com>/dev/null 2>&1`

VPN_USER="seovpn" #You may choose to modify to increase security, however, isn't required. 
VPN_PASS="20150709010553" #Please modify, this password isn't secure.

VPN_LOCAL="192.168.0.150" #In general, do not modify.
VPN_REMOTE="192.168.0.151-200" #In general, do not modify.

yum -y groupinstall "Development Tools"
rpm -Uvh https://web.archive.org/web/20150709010553/http://poptop.sourceforge.net/yum/stable/rhel6/pptp-release-current.noarch.rpm #Archived version from Sourceforge
yum -y install policycoreutils policycoreutils
yum -y install ppp pptpd
yum -y update

echo "1" > /proc/sys/net/ipv4/ip_forward
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf

sysctl -p /etc/sysctl.conf

echo "localip $VPN_LOCAL" >> /etc/pptpd.conf # Local IP address of your VPN server
echo "remoteip $VPN_REMOTE" >> /etc/pptpd.conf # Scope for your home network


echo "ms-dns 77.88.8.8" >> /etc/ppp/options.pptpd # Yandex DNS Primary //https://dns.yandex.com
echo "ms-dns 77.88.8.1" >> /etc/ppp/options.pptpd # Yandex DNS Secondary //https://dns.yandex.com
echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd # Google DNS Primary //https://developers.google.com/speed/public-dns/
echo "ms-dns 8.8.4.4" >> /etc/ppp/options.pptpd # Google DNS Secondary //https://developers.google.com/speed/public-dns/
echo "ms-dns 208.67.222.222" >> /etc/ppp/options.pptpd # OpenDNS DNS Primary //https://use.opendns.com/
echo "ms-dns 208.67.220.220" >> /etc/ppp/options.pptpd # OpenDNS DNS Secondary //https://use.opendns.com/

echo "$VPN_USER pptpd $VPN_PASS *" >> /etc/ppp/chap-secrets

service iptables start
echo "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE" >> /etc/rc.local
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
service iptables save
service iptables restart

service pptpd restart
chkconfig pptpd on

echo -e '\E[37;44m'"\033[1m Installation Log: /var/log/vpn-installer.log \033[0m"
echo -e '\E[37;44m'"\033[1m You can now connect to your VPN via your external IP ($VPN_IP)\033[0m"

echo -e '\E[37;44m'"\033[1m Username: $VPN_USER\033[0m"
echo -e '\E[37;44m'"\033[1m Password: $VPN_PASS\033[0m"

) 2>&1 | tee /var/log/vpn-installer.log
