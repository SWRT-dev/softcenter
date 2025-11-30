#! /bin/sh
# 导入skipd数据
eval `dbus export softether_`

# 引用环境变量等
source /jffs/softcenter/scripts/base.sh
comment="SoftEtherVPN_rule"
runDir=/tmp/softethervpn
binDir=/jffs/softcenter/bin
[ -d "$runDir" ] || mkdir -p -m 0775 $runDir

# 使iptables能作备注
load_xt_comment(){
	local CM=$(lsmod | grep xt_comment)
	local OS=$(uname -r)
	if [ -z "${CM}" -a -f "/lib/modules/${OS}/kernel/net/netfilter/xt_comment.ko" ];then
		insmod /lib/modules/${OS}/kernel/net/netfilter/xt_comment.ko
		logger "[软件中心]：SoftEtherVPN：已加载xt_comment.ko内核模块"
	fi
}
# 写防火墙规则
write_ipt(){
	local TP=$1
	local Pt=$2
	local IP=$3
	[ -z "${IP}" ] && IP=iptables
	[ "${IP}" == "6" ] && IP=ip6tables
	${IP} -I INPUT -p ${TP} --dport ${Pt} -m comment --comment "${comment}" -j ACCEPT >/dev/null 2>&1
}
# 打开端口
open_port(){
	[ -z "${softether_tcp_ports}" ] && [ -z "${softether_udp_ports}" ] && return 1
	load_xt_comment

	local port t_port v6_t_port u_port v6_u_port
	if [ -n "${softether_tcp_ports}" ];then
		for port in ${softether_tcp_ports}
		do
		[ "$port" -gt 65535 -o "$port" -lt 1 ] && continue
		[ "${port:0:1}" == "0" ] && port=$(expr "$port" + 0)
		write_ipt tcp ${port}
		[ -n "${t_port}" ] && t_port="${t_port} "
		t_port="${t_port}${port}"
		if [ "${softether_tcp_v6}" == "1" ]; then
			write_ipt tcp ${port} 6
			[ -n "${v6_t_port}" ] && v6_t_port="${v6_t_port} "
			v6_t_port="${v6_t_port}${port}"
		fi
		done   
	fi
	if [ -n "${softether_udp_ports}" ];then
		for port in ${softether_udp_ports}
		do
		[ "$port" -gt 65535 -o "$port" -lt 1 ] && continue
		[ "${port:0:1}" == "0" ] && port=$(expr "$port" + 0)
		write_ipt udp ${port}
		[ -n "${u_port}" ] && u_port="${u_port} "
		u_port="${u_port}${port}"
		if [ "${softether_udp_v6}" == "1" ]; then
			write_ipt udp ${port} 6
			[ -n "${v6_u_port}" ] && v6_u_port="${v6_u_port} "
			v6_u_port="${v6_u_port}${port}"
		fi
		done
	fi
	if [ -n "${t_port}${u_port}${v6_t_port}${v6_u_port}" ]; then
		[ -n "${t_port}" ] && t_port="TCPv4：$t_port，"
		[ -n "${u_port}" ] && u_port="UDPv4：$u_port，"
		[ -n "${v6_t_port}" ] && v6_t_port="TCPv6：$v6_t_port，"
		[ -n "${v6_u_port}" ] && v6_u_port="UDPv6：$v6_u_port"
		logger "[软件中心]：SoftEtherVPN 打开端口入站[${t_port}${u_port}${v6_t_port}${v6_u_port}]"
	fi
}
# 关闭端口
close_port(){
	local IPTS=$(iptables -t filter -S INPUT | grep -w "${comment}")
	local IPTS6=$(ip6tables -t filter -S INPUT | grep -w "${comment}")
	[ -z "${IPTS}" ] && [ -z "${IPTS6}" ] && return 1
	local tmp_file=$runDir/clean_Softether_rule.sh
	logger "[软件中心]：softetherVPN 关闭其在防火墙上打开的所有端口"
	[ -n "${IPTS}" ] && echo "${IPTS}" | sed 's/-A/iptables -D/g' > $tmp_file
	[ -n "${IPTS6}" ] && echo "${IPTS6}" | sed 's/-A/ip6tables -D/g' >> $tmp_file
	chmod +x $tmp_file
	sh $tmp_file >/dev/null 2>&1
	rm $tmp_file
}
# 配置文件TMP模式（存至RAM）
do_conf_tmp(){
	local act=$1
	local CONF=$binDir/vpn_server.config
	local TEMP=$runDir/vpn_server.config
	
	if [ "$act" == "start" ];then
		if [ "$softether_conf_TMP" -eq 1 ];then	
			[ -f "$CONF" ] && cp -f $CONF $TEMP || rm -f $TEMP
			[ "$softether_conf_cron_type" == "day" ] && cru a By_softetherVPN "00 00 */${softether_conf_cron_time} * * /jffs/softcenter/scripts/softether_config.sh record"
			[ "$softether_conf_cron_type" == "hour" ] && cru a By_softetherVPN "00 */${softether_conf_cron_time2} * * * /jffs/softcenter/scripts/softether_config.sh record"
		fi
	elif [ "$act" == "stop" ];then
		# 恢复配置至闪存
		[ ! -L "$TEMP" ] && mv -f $TEMP $CONF
		[ -n "$(cru l |grep -w 'By_softetherVPN')" ] && cru d By_softetherVPN
	fi
}
# 修改配置
do_conf_fix(){
	[ -n "$softether_lang" ] && [ -z "$(tail -n 3 $binDir/lang.config |grep -w $softether_lang)" ] && echo $softether_lang >$binDir/lang.config
	[ -n "$softether_AutoSaveConfigSpan" ] && {
		val=`grep AutoSaveConfigSpan $binDir/vpn_server.config |awk '{print $3}'`
		[ -n "$val" ] && [ "$val" != "$softether_AutoSaveConfigSpan" ] && sed -i "s/uint AutoSaveConfigSpan $val/uint AutoSaveConfigSpan $softether_AutoSaveConfigSpan/g" $binDir/vpn_server.config
	}
	[ -n "$softether_DisableJsonRpcWebApi" ] && {
		val=`grep DisableJsonRpcWebApi $binDir/vpn_server.config |awk '{print $3}'`
		[ -n "$val" ] && [ "$val" != "$softether_DisableJsonRpcWebApi" ] && sed -i "s/bool DisableJsonRpcWebApi $val/bool DisableJsonRpcWebApi $softether_DisableJsonRpcWebApi/g" $binDir/vpn_server.config
	}
	dbus set softether_conf_fix=0  #改1次即可
}

# 开启服务
start_vpn() {
	[ "$softether_enable" == "1" ] || exit
	mod=`lsmod |grep -w tun`
	if [ -z "$mod" ];then
		modprobe tun
	fi
	[ -x "$binDir/vpnserver" ] || chmod +x $binDir/vpnserver
	[ -f "$binDir/vpncmd" ] && { [ -x "$binDir/vpncmd" ] || chmod +x $binDir/vpncmd; [ -L "$runDir/vpncmd"  ] || ln -sf $binDir/vpncmd $runDir/; }
	[ -L "$runDir/vpn_server.config" ] || ln -sf $binDir/vpn_server.config $runDir/
	[ -L "$runDir/vpnserver" ] || ln -sf $binDir/vpnserver $runDir/
	[ -L "$runDir/hamcore.se2" ] || ln -sf $binDir/hamcore.se2 $runDir/
	[ -L "$runDir/lang.config" ] || ln -sf $binDir/lang.config $runDir/
	
	do_conf_tmp start

	if [ "$softether_foreground" != "1" ];then
		$runDir/vpnserver start
	else
		$runDir/vpnserver start --foreground >/dev/null 2>&1 &
	fi
	
	open_port
	
	if [ ! -L "/jffs/softcenter/init.d/N98softether.sh" ]; then
		ln -sf /jffs/softcenter/scripts/softether_config.sh /jffs/softcenter/init.d/N98softether.sh
		# ln -sf /jffs/softcenter/scripts/softether_config.sh /jffs/softcenter/init.d/S98softether.sh
	fi

	local i=30
	local tap
	until [ -n "$tap" ]
	do
		i=$(($i-1))
		tap=`ifconfig | grep tap_ | awk '{print $1}'`
		if [ "$i" -lt 1 ];then
			logger "[软件中心]: 已启动softetherVPN，但未发现网桥tap设备，请按需配置"
			break
		fi
		sleep 2
	done

	# 监测进程
	if [ -n "$softether_watch_time" ]; then
	echo "`pidof vpnserver`" >$runDir/vpn_server__watch.pid
	cat > $runDir/vpn_server__watch.sh <<\EOF
#! /bin/sh

CURRENT_PID=`pidof vpnserver`
if [ -z "$CURRENT_PID" ]; then
	logger "[$0]:进程 vpnserver 未找到，重启"
	/jffs/softcenter/scripts/softether_config.sh restart &
	exit
fi
PID_file=/tmp/softethervpn/vpn_server__watch.pid   #目录是主脚本 runDir 定义的实际值，勿用变量
Saved_PID=`cat $PID_file`

if [ "$CURRENT_PID" != "$Saved_PID" ]; then
	echo "$CURRENT_PID" >$PID_file
	logger "[$0]:进程 vpnserver 的PID变化! 原: $Saved_PID, 新: $CURRENT_PID"

	tap=`ifconfig |grep tap_ |awk '{print $1}'`
	[ -n "$tap" ] && [ -z "`brctl show br0 |grep -w $tap`" ] && brctl addif br0 $tap && logger "[$0]:softetherVPN 修复网桥"
fi
EOF
	cru a softether_watch "*/$softether_watch_time * * * * $runDir/vpn_server__watch.sh"
	chmod 0755 $runDir/vpn_server__watch.sh
	fi

	#若使用网桥模式，需将tap桥接到lan
	[ -n "$tap" ] || return
	brctl addif br0 $tap >/dev/null 2>&1
	
# 	echo interface=$tap > /etc/dnsmasq.user/softether.conf
# 	service restart_dnsmasq
	
	logger "[软件中心]: 已启动softetherVPN"
}
stop_vpn(){
	pid=`pidof vpnserver`
	if [ -n "$pid" ];then
		$runDir/vpnserver stop
		[ "$?" != "0" ] && kill -9 $pid 2>/dev/null
		logger "[软件中心]: 已停止softetherVPN进程"
	fi

	if [ "$softether_enable" != "1" ]; then
		rm -f /jffs/softcenter/init.d/?98softether.sh
#		rm -f /etc/dnsmasq.user/softether.conf
#		service restart_dnsmasq
	fi

	do_conf_tmp stop
	
	close_port
	
	[ "$softether_conf_fix" == "1" ] && do_conf_fix
	
	#删除监测
	[ -n "$(cru l |grep -w 'softether_watch')" ] && cru d softether_watch
	rm -f $runDir/vpn_server__watch.*
}

case $1 in
start|restart)
	stop_vpn
	start_vpn
	;;
stop)
	stop_vpn
	;;
start_nat)
	sleep 2
	if [ -n "$(pidof vpnserver)" ]; then
		# 网页端更改LAN口网络设置，可能导致VPN桥接失效
		tap=`ifconfig | grep tap_ | awk '{print $1}'`
		if [ -n "$tap" ] && [ -z "`brctl show br0 | grep -w $tap`" ];then
			brctl addif br0 $tap
			logger "[软件中心]：softetherVPN 修复网桥"
		fi
		close_port
		open_port
	else
		start_vpn
	fi
	;;
esac

case $2 in
web_submit)
	stop_vpn
	start_vpn
	;;
record)
	[ -n "$(pidof vpnserver)" ] && [ ! -L "$runDir/vpn_server.config" ] && cp -f $runDir/vpn_server.config $binDir/
	;;
modconf)
	[ -n "$(pidof vpnserver)" ] || do_conf_fix
	;;
log_lnk)
	mkdir -p /tmp/upload
	ln -sf $runDir/server_log/vpn_$(date +%Y%m%d).log /tmp/upload/softether_server_log.lnk
	;;
esac
