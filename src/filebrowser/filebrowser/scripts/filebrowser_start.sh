#!/bin/sh

source /jffs/softcenter/scripts/base.sh

# 导入数据（注意：将合并连续的空格）
eval `dbus export filebrowser_`

alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
mkdir -p /tmp/upload
mkdir -p /var/run
LOG_FILE=/tmp/upload/FileBrowser.log
bin_file=/jffs/softcenter/bin/filebrowser
dbfile=/jffs/softcenter/bin/filebrowser.db
port=$filebrowser_port
comment="Filebrowser_rule"

case "$filebrowser_ip" in
	"Lan_ip4")  ip=$(nvram get lan_ipaddr) ;;
	"Wan_ip4")  ip=$(nvram get wan_ipaddr) ;;
	*)		  ip="$filebrowser_ip" ;;
esac
[ -z "$ip" ] && ip="0.0.0.0"

# 自启或事件触发
auto_start() {
	[ "$filebrowser_enable" == "1" ] && {
	if [ ! -L "/jffs/softcenter/init.d/N99filebrowser.sh" ]; then
		ln -sf /jffs/softcenter/scripts/filebrowser_start.sh /jffs/softcenter/init.d/N99filebrowser.sh
		# ln -sf /jffs/softcenter/scripts/filebrowser_start.sh /jffs/softcenter/init.d/S99filebrowser.sh
		echo_date "创建NAT触发任务"
	fi
	}
}
del_auto_start() {
	[ "$filebrowser_enable" != "1" ] && {
	if [ -L "/jffs/softcenter/init.d/N99filebrowser.sh" ];then
		echo_date "删除启动触发"
		rm -f /jffs/softcenter/init.d/?99filebrowser.sh
	fi
	}
}

# 看门狗动作
watch_dog(){
	if [ -z "$(pidof filebrowser)" ]; then
		#先执行清除缓存
		sync
		echo 1 > /proc/sys/vm/drop_caches
		sleep 1s
		echo_date "进程丢失，看门狗重新拉起FileBrowser"
		run_fb
	fi
}
# 关看门狗
del_watchdog_job(){
	local DOG=$(cru l | grep filebrowser_watchdog)
	if [ -n "$DOG" ];then
		echo_date "删除看门狗定时任务"
		cru d filebrowser_watchdog
	fi
}
# 开看门狗
write_watchdog_job(){
	if [ "$filebrowser_watchdog" != "1" ]; then
		del_watchdog_job
		return 1
	fi
	echo_date "创建看门狗定时任务"
	cru a filebrowser_watchdog "*/${filebrowser_delay_time} * * * * pidof filebrowser >/dev/null || /jffs/softcenter/scripts/filebrowser_start.sh watch"
}
# 使iptables能作备注
load_xt_comment(){
	local CM=$(lsmod | grep xt_comment)
	local OS=$(uname -r)
	if [ -z "${CM}" -a -f "/lib/modules/${OS}/kernel/net/netfilter/xt_comment.ko" ];then
		insmod /lib/modules/${OS}/kernel/net/netfilter/xt_comment.ko
		echo_date "已加载xt_comment.ko内核模块"
	fi
}
# 关闭端口
close_port(){
	local IPTS=$(iptables -t filter -S INPUT | grep -w "${comment}")
	local IPTS6=$(ip6tables -t filter -S INPUT | grep -w "${comment}")
	[ -z "${IPTS}" ] && [ -z "${IPTS6}" ] && return 1
	local tmp_file=/tmp/Clean_filebrowser_$$
	echo_date "关闭本插件当前打开的所有端口"
	[ -n "${IPTS}" ] && echo "${IPTS}" | sed 's/-A/iptables -D/g' > ${tmp_file}
	[ -n "${IPTS6}" ] && echo "${IPTS6}" | sed 's/-A/ip6tables -D/g' >> ${tmp_file}
	chmod +x ${tmp_file}
	/bin/sh ${tmp_file} >/dev/null 2>&1
	rm ${tmp_file}
}
# 打开端口
open_port(){
if [ "${filebrowser_publicswitch}" == "1" ] && [ "$ip" == "0.0.0.0" ]; then
	load_xt_comment
	echo_date "打开IPv4/IPv6 TCP端口：${port}"
	iptables -I INPUT -p tcp --dport ${port} -m comment --comment "${comment}" -j ACCEPT >/dev/null 2>&1
	ip6tables -I INPUT -p tcp --dport ${port} -m comment --comment "${comment}" -j ACCEPT >/dev/null 2>&1
fi
}
# 停止进程(先常规，再强制)
kill_fb(){
	local PID=$(pidof filebrowser)
	if [ -n "${PID}" ];then
		start-stop-daemon -K -p /var/run/filebrowser.pid >/dev/null 2>&1
		sleep 1 && kill -9 "${PID}" >/dev/null 2>&1
		echo_date "已关闭当前filebrowser进程"
	fi
	rm -f /var/run/filebrowser.pid
}
# 恢复数据库
upload_db(){
	# 用户上传的文件名不可控，要dbus get，以免有连续空格被忽略，且要加双引号
	upload_dbname=`dbus get filebrowser_uploaddatabase`
	if [ -f "/tmp/upload/$upload_dbname" ]; then
		echo_date "执行数据库恢复工作"
		[ -n "$(pidof filebrowser)" ] && fb_id=1
		kill_fb
		mv -f "/tmp/upload/$upload_dbname" $dbfile
		if [ "$?" == "0" ];then
			echo_date "已完成数据库恢复"
			[ "${fb_id}" == "1" ] && run_fb
		fi
		dbus remove filebrowser_uploaddatabase
	else
		echo_date "上传失败，没找到数据库文件"
	fi
}
#删除数据库
rm_db(){
	[ -f "$dbfile" ] || {
		echo_date "无数据库文件可删除"
		return 1
	}
	echo_date "即将删除数据库文件"
	[ -n "$(pidof filebrowser)" ] && close_fb
	rm -f $dbfile
	echo_date "已删除数据库文件"
}
# 关闭服务并清理
close_fb(){
	kill_fb
	del_watchdog_job
	close_port
	del_auto_start
	echo_date "已清理filebrowser服务"
}
run_fb(){
	echo_date "FileBrowser启动中..."

	cert=$filebrowser_cert
	key=$filebrowser_key

	local SSL_PARAMS=""
	[ -x "$bin_file" ] || chmod 0755 $bin_file
	if [ "${filebrowser_sslswitch}" == "1" ]; then
		if [ -f "${cert}" ] && [ -f "${key}" ]; then
			SSL_PARAMS="-t ${cert} -k ${key}"
			echo_date "使用自定义证书启用TLS/SSL"
		elif [ -f "/etc/cert.pem" ] && [ -f "/etc/key.pem" ]; then
			SSL_PARAMS="-t /etc/cert.pem -k /etc/key.pem"
			echo_date "使用系统内置证书启用TLS/SSL"
		fi
		if [ -z "${SSL_PARAMS}" ]; then
			echo_date "证书/密钥无效或不匹配，无法启用TLS/SSL，退出程序！"
			return 1
		fi
	fi
	Arg="-a $ip -p $port -r / -d $dbfile $SSL_PARAMS $filebrowser_extrFlag"
	
	# 启动时sh -c要执行的命令前面加一个exec，使父进程/bin/sh被子进程filebrowser替换，以免pid不一样出现异常
	start-stop-daemon -S -q -b -m -p /var/run/filebrowser.pid -a /bin/sh -- -c "exec $bin_file $Arg >>$LOG_FILE 2>&1"
	
	local fb_pid
	local i=16
	until [ -n "$fb_pid" ]; do
		i=$(($i - 1))
		fb_pid=$(pidof filebrowser)
		if [ "$i" -lt 1 ]; then
			echo_date "启动失败！"
			return 1
		fi
		sleep 1
	done
	echo_date "启动完成，pid：$fb_pid"
}
# 开启服务
start_fb(){
	[ "$filebrowser_enable" != "1" ] && {
		close_fb
		echo_date "FileBrowser被禁用"
		return
	}
	
	kill_fb
	[ -f "$dbfile" ] || firstStart=1
	
	run_fb

	auto_start
	write_watchdog_job
	close_port
	open_port
	logger "【软件中心】启动FileBrowser，pid：$fb_pid"
	
	[ "$firstStart" = "1" ] && {
		i=16; str=""
		until [ -n "$str" ]; do
		i=$(($i - 1))
		[ "$i" -lt 0 ] && break
		str=$(grep 'password' $LOG_FILE |grep 'admin' | awk '{print $NF}')
		sleep 1
		done
		echo_date "首次启动，及时更改用户 admin 的初始密码 $str"
		dbus set filebrowser_firstPWD=$str
	} || { [ -n "$filebrowser_firstPWD" ] && dbus remove filebrowser_firstPWD; }
}

case $1 in
start|restart)
	start_fb | tee -a $LOG_FILE
	;;
stop)
	close_fb | tee -a $LOG_FILE
	;;
watch)
	watch_dog | tee -a $LOG_FILE
	;;
start_nat)
	sleep 1
	if [ -z "$(pidof filebrowser)" ] || [ "$ip" != "0.0.0.0" ]; then
		echo_date "NAT触发：FileBrowser启动..." | tee -a $LOG_FILE
		start_fb | tee -a $LOG_FILE
	else
		echo_date "NAT触发：FileBrowser检查防火墙端口" | tee -a $LOG_FILE
		close_port | tee -a $LOG_FILE
		open_port | tee -a $LOG_FILE
	fi
	;;
esac

case $2 in
web_submit)
	true > $LOG_FILE
	echo_date "开启FileBrowser" | tee -a $LOG_FILE
	start_fb | tee -a $LOG_FILE
	;;
upload)
	upload_db | tee -a $LOG_FILE
	;;
download)
	echo_date "即将备份数据库文件" | tee -a $LOG_FILE
	cp -f $dbfile /tmp/upload/filebrowser.db
	if [ "$?" == "0" ]; then
		echo_date "文件已复制，响应下载" | tee -a $LOG_FILE
		http_response "$1"
	else
		echo_date "文件复制失败，无法下载" | tee -a $LOG_FILE
		http_response "fail"
	fi
	;;
rmdb)
	true > $LOG_FILE
	rm_db | tee -a $LOG_FILE
	;;
esac

