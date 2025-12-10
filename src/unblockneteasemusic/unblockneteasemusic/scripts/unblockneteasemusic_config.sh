#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval `dbus export unblockneteasemusic_`
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

ROUTE_IP=$(nvram get lan_ipaddr)
IPT_N="iptables -t nat"
IPT_INPUT_RULE="unm_input_rule"
serverCrt="/jffs/softcenter/bin/Music/server.crt"
serverKey="/jffs/softcenter/bin/Music/server.key"
LOG_FILE=/tmp/upload/unblockneteasemusic_log.txt
echo "" > $LOG_FILE

add_rule()
{
	echo_date 加载nat规则...
	echo_date Load nat rules...
	ipset -! -N music hash:ip
	wget -q -t 99 -T 10 http://httpdns.n.netease.com/httpdns/v2/d?domain=music.163.com,interface.music.163.com,interface3.music.163.com,apm.music.163.com,apm3.music.163.com,clientlog.music.163.com,clientlog3.music.163.com -O- | grep -Eo '[0-9]+?\.[0-9]+?\.[0-9]+?\.[0-9]+?' | sort | uniq | awk '{print "ipset -! add music "$1}' | sh
	$IPT_N -N cloud_music
	$IPT_N -A cloud_music -d 0.0.0.0/8 -j RETURN
	$IPT_N -A cloud_music -d 10.0.0.0/8 -j RETURN
	$IPT_N -A cloud_music -d 127.0.0.0/8 -j RETURN
	$IPT_N -A cloud_music -d 169.254.0.0/16 -j RETURN
	$IPT_N -A cloud_music -d 172.16.0.0/12 -j RETURN
	$IPT_N -A cloud_music -d 192.168.0.0/16 -j RETURN
	$IPT_N -A cloud_music -d 224.0.0.0/4 -j RETURN
	$IPT_N -A cloud_music -d 240.0.0.0/4 -j RETURN
	$IPT_N -A cloud_music -p tcp --dport 80 -j REDIRECT --to-ports 5200
	$IPT_N -A cloud_music -p tcp --dport 443 -j REDIRECT --to-ports 5300
	$IPT_N -I PREROUTING -p tcp -m set --match-set music dst -j cloud_music
	if [ "$unblockneteasemusic_wan" = "1" ];then
		iptables -N "$IPT_INPUT_RULE"
		iptables -t filter -I INPUT -j "$IPT_INPUT_RULE"
		iptables -t filter -A "$IPT_INPUT_RULE" -p tcp --dport 5200 -j ACCEPT
		iptables -t filter -A "$IPT_INPUT_RULE" -p tcp --dport 5300 -j ACCEPT
	fi
}

del_rule(){
	echo_date 移除nat规则...
	echo_date Unload nat rules...
	iptables -t filter -D INPUT -j "$IPT_INPUT_RULE" 2>/dev/null
	iptables -F "$IPT_INPUT_RULE" 2>/dev/null
	iptables -X "$IPT_INPUT_RULE" 2>/dev/null
	$IPT_N -D PREROUTING -p tcp -m set --match-set music dst -j cloud_music 2>/dev/null
	$IPT_N -F cloud_music  2>/dev/null
	$IPT_N -X cloud_music  2>/dev/null
	ipset flush music 2>/dev/null
	echo_date 重启dnsmasq
	rm -f /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	service restart_dnsmasq
}

set_firewall(){

	rm -f /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "dhcp-option=252,http://${ROUTE_IP}:5200/proxy.pac" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/interface.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/interface3.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/apm.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/apm3.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/clientlog.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo "ipset=/clientlog3.music.163.com/music" >> /tmp/etc/dnsmasq.user/dnsmasq-music.conf
	echo_date 重启dnsmasq
	service restart_dnsmasq
	add_rule
}

start_unblockmusic(){
	local cookie args cookies
	if [ "$unblockneteasemusic_enable" == "1" ];then
		echo_date 开启unblockneteasemusic
		if [ "$unblockneteasemusic_musicapptype" = "qq" ]; then
			cookie=`echo $unblockneteasemusic_cookie | base64 -d`
			cookies="QQ_COOKIE=${cookie}"
		elif [ "$unblockneteasemusic_musicapptype" = "migu" ]; then
			cookie=`echo $unblockneteasemusic_cookie | base64 -d`
			cookies="MIGU_COOKIE=${cookie}"
		elif [ "$unblockneteasemusic_musicapptype" = "kugou" ]; then
			cookie=`echo $unblockneteasemusic_cookie | base64 -d`
			cookies="KUWO_COOKIE=${cookie}"
		fi
		set_firewall
		args=""
		if [ "$unblockneteasemusic_musicapptype" == "default" ]; then
			args=" -o kugou kuwo bilibili bodian"
		else
			args=" -o $unblockneteasemusic_musicapptype"
		fi
		env LOG_LEVEL=error LOG_FILE=/tmp/unblockmusic.log SIGN_CERT=${serverCrt} SIGN_KEY=${serverKey} DISABLE_UPGRADE_CHECK=true BLOCK_ADS=true MIN_BR="9999999" ENABLE_FLAC=true ENABLE_LOCAL_VIP=true ${cookies} /jffs/softcenter/bin/node /jffs/softcenter/bin/Music/app.js -a 0.0.0.0 -p 5200:5300 -e "https://music.163.com" -s ${args} &
		echo_date unblockneteasemusic已启动
		mkdir -p /var/wwwext
		cp -f /jffs/softcenter/bin/Music/ca.crt /www/ext
		echo_date 建立证书链接
	#	ln -sf /jffs/softcenter/scripts/unblockneteasemusic_config.sh /jffs/softcenter/init.d/S99unblockneteasemusic.sh
		echo_date 添加每日自动重启插件任务
		sed -i '/unmupdate/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
		cru a unmupdate "30 2 * * * /jffs/softcenter/scripts/unblockneteasemusic_config.sh restart"
		echo_date unblockneteasemusic启动完毕
	fi
}

stop_unblockmusic(){
	echo_date 关闭unblockneteasemusic

	kill -9 $(ps -w | grep app.js | grep -v grep | awk '{print $1}') >/dev/null 2>&1
	rm -f /tmp/unblockmusic.log
	echo_date 删除每日自动重启插件任务
	sed -i '/unmupdate/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	del_rule
	#if [ "$unblockneteasemusic_enable" == "0" ]; then
	#	rm -f /jffs/softcenter/init.d/*unblockneteasemusic.sh
	#fi
}

case $1 in
start|start_nat)
	stop_unblockmusic >> $LOG_FILE
	start_unblockmusic >> $LOG_FILE
	echo XU6J03M6 >> $LOG_FILE
	;;
stop)
	stop_unblockmusic >> $LOG_FILE
	echo XU6J03M6 >> $LOG_FILE
	;;
esac

case $2 in
web_submit)
	stop_unblockmusic >> $LOG_FILE
	start_unblockmusic >> $LOG_FILE
	echo XU6J03M6 >> $LOG_FILE
	;;
esac

