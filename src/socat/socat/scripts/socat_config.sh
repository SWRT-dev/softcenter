#!/bin/sh

# 环境
source /jffs/softcenter/scripts/base.sh
eval `dbus export socat_`
script_dir=/jffs/softcenter/scripts
init_dir=/jffs/softcenter/init.d
remarks="Socat_rule"
firewall_rule=/tmp/Socat/add_rule.sh
mkdir -p /tmp/Socat

# 添加定时
cru_job(){
	if [ -z "$socat_cron_type" ] || [ "$socat_enable" != "1" ]; then
		[ -n "$(cru l |grep -w 'socat_watch')" ] && cru d socat_watch
		return
	fi
	[ "$socat_cron_type" == "min" ] && cru a socat_watch "*/${socat_cron_time_min} * * * * ${script_dir}/socat_config.sh restart"
	[ "$socat_cron_type" == "hour" ] && cru a socat_watch "00 */${socat_cron_time_hour} * * * ${script_dir}/socat_config.sh restart"
}
# 使iptables能作备注（打开/关闭端口依赖）
load_xt_comment(){
	local CM=$(lsmod | grep xt_comment)
	local OS=$(uname -r)
	if [ -z "${CM}" -a -f "/lib/modules/${OS}/kernel/net/netfilter/xt_comment.ko" ];then
		insmod /lib/modules/${OS}/kernel/net/netfilter/xt_comment.ko
		logger "[软件中心]：Socat 已加载xt_comment.ko内核模块"
	fi
}
close_port(){
	local IPTS=$(iptables -t filter -S INPUT | grep -w "${remarks}")
	local IPTS6=$(ip6tables -t filter -S INPUT | grep -w "${remarks}")
	[ -z "${IPTS}" ] && [ -z "${IPTS6}" ] && return 1
	local tmp_file=/tmp/Socat/clean_rule.sh
	[ -n "${IPTS}" ] && echo "${IPTS}" | sed 's/-A/iptables -D/g' > $tmp_file
	[ -n "${IPTS6}" ] && echo "${IPTS6}" | sed 's/-A/ip6tables -D/g' >> $tmp_file
	chmod +x $tmp_file
	sh $tmp_file >/dev/null 2>&1
	rm $tmp_file
}
run_service() {
	[ "$socat_enable" != "1" ] && return
	
	server_nu=`dbus list socat_family_node | sort -n -t "_" -k 4|cut -d "=" -f 1|cut -d "_" -f 4`
	[ -z "$server_nu" ] && return
	
	bin_ver=`socat -V | grep 'socat version' |awk '{print $3}'`
	[ "$socat_bin_version" != "$bin_ver" ] && dbus set socat_bin_version=$bin_ver   #仅登记版本

	true >$firewall_rule

	for nu in ${server_nu}
	do
		eval family=\$socat_family_node_$nu
		eval proto=\$socat_proto_node_$nu
		eval listen_port=\$socat_listen_port_node_$nu
		eval reuseaddr=\$socat_reuseaddr_node_$nu
		eval dest_proto=\$socat_dest_proto_node_$nu
		eval dest_ip=\$socat_dest_ip_node_$nu
		eval dest_port=\$socat_dest_port_node_$nu
		eval firewall_accept=\$socat_firewall_accept_node_$nu
		
		[ "$reuseaddr" == "on" ] && reuseaddr=",reuseaddr" || reuseaddr=""

		if [ "$family" == "v6" ]; then
			ipv6only_params=",ipv6-v6only"; family=6
		elif [ "$family" == "v4" ]; then
			ipv6only_params=""; family=4
		elif [ "$family" == "v4/v6" ]; then
			ipv6only_params=""; family=""
		fi
		
		listen=${proto}${family}
		[ "$family" == "" ] && listen=${proto}6
		
		socat ${listen}-listen:${listen_port}${ipv6only_params}${reuseaddr},fork ${dest_proto}:${dest_ip}:${dest_port} >/dev/null 2>&1 &
		
		[ "$firewall_accept" == "on" ] && {
			if [ -z "$family" ] || [ "$family" == "6" ]; then
				echo "ip6tables -I INPUT -p $proto --dport $listen_port -m comment --comment \"$remarks\" -j ACCEPT" >>$firewall_rule
			fi
			if [ -z "$family" ] || [ "$family" == "4" ]; then
				echo "iptables -I INPUT -p $proto --dport $listen_port -m comment --comment \"$remarks\" -j ACCEPT" >>$firewall_rule
			fi
		}
	done
	
	[ -n "$(cat $firewall_rule)" ] && {
		load_xt_comment
		chmod +x $firewall_rule
		sh $firewall_rule >/dev/null 2>&1
	}
	
	cru_job
	
	if [ ! -L "${init_dir}/N99socat.sh" ]; then
		ln -sf ${script_dir}/socat_config.sh ${init_dir}/N99socat.sh
		# ln -sf ${script_dir}/socat_config.sh ${init_dir}/S99socat.sh
	fi
	logger "【软件中心】：已启动 Socat"
}
stop_service() {
	pid=`pidof socat`
	[ -n "$pid" ] && {
		killall socat
		sleep 1 && kill -9 $pid >/dev/null 2>&1
	}
	close_port
	rm -f $firewall_rule
	[ -n "$(cru l |grep -w 'socat_watch')" ] && cru d socat_watch
	[ "$socat_enable" != "1" ] && rm -f ${init_dir}/?99socat.sh
}

case $1 in
start|restart)
	stop_service
	run_service
	;;
stop)
	stop_service
	;;
start_nat)
	sleep 3
	if [ -n "$(pidof socat)" ]; then
		close_port
		[ -n "$(cat $firewall_rule)" ] && sh $firewall_rule >/dev/null 2>&1
	else
		run_service
	fi
	;;
esac

# for 网页提交
case $2 in
1)
	stop_service
	run_service
	http_response "$1"
	;;
esac
