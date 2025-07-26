#!/bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export openlist_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/openlist_log.txt
RUN_LOG_link=/tmp/upload/openlist_run_log.lnk
LOCK_FILE=/var/lock/openlist.lock
PID_FILE=/var/run/openlist.pid
mkdir -p /tmp/upload /var/run
cfgFail=""
firstPWD=""

# 初始化配置变量
###########################################
conf_init() {
	local var_name="$1"  # 存储结果的变量名
	local value="$2"	 # 要检查的值
	local default="$3"   # 默认值

	if [ -n "$value" ]; then
		eval "$var_name=\"$value\""  # 动态赋值给外部变量
	else
		eval "$var_name=\"$default\""
	fi
}
#主程序路径
conf_init PROG "$openlist_bin_file" /jffs/softcenter/bin/openlist

#面板端口
conf_init PORT "$openlist_port" 5244

#数据目录
conf_init DATA "$openlist_data_dir" /jffs/softcenter/openlist

#监听地址，优先lan口地址
conf_init address "$(nvram get lan_ipaddr)" 0.0.0.0

#开启公网访问后
[ "$openlist_publicswitch" -eq 1 ] && {
	#监听地址
	address="0.0.0.0"
	
	#网站URL和资源CDN地址（初始json中为空），因地址可能包含特殊字符$，经eval解析会变为变量导致字符串改变，故重新dbus get
	site_url=$(dbus get openlist_site_url)
	cdn=$(dbus get openlist_cdn)
}

# 开启https后
if [ "$openlist_https" -eq 1 ]; then
	https_port=$PORT; http_port="-1"
	
	# 证书Cert文件和Key文件（初始json中为空）
	conf_init cert_file "$openlist_cert_file" /etc/cert.pem
	conf_init key_file "$openlist_key_file" /etc/key.pem
else
	https_port="-1"; http_port=$PORT
fi

#延迟启动时间
conf_init delayed_start "$openlist_delayed_start" 0
#用户登录过期时间
conf_init token_expires_in "$openlist_token_expires_in" 48
#最大并发连接数
conf_init max_connections "$openlist_max_connections" 0
#缓存目录
conf_init temp_dir "$openlist_tmp_dir" /tmp/openlist
#禁用 TLS 验证
conf_init tls_insecure_skip_verify "$openlist_tls_insecure_skip_verify" true

#运行日志，含标准输出重定向
conf_init log_enable "$openlist_log_enable" true
conf_init log_name "$openlist_log_name" /tmp/openlist_run.log

#FTP和SFTP（注意写json配置时端口是加冒号的字符串）
conf_init ftp_enable "$openlist_ftp_enable" false
conf_init ftp_port "$openlist_ftp_port" 5221
conf_init sftp_enable "$openlist_sftp_enable" false
conf_init sftp_port "$openlist_sftp_port" 5222

# S3功能
conf_init s3_enable "$openlist_s3_enable" false
conf_init s3_port "$openlist_s3_port" 5246
conf_init s3_ssl "$openlist_s3_ssl" false

###########################################

# 加锁（非阻塞）
set_lock(){
	exec 933>${LOCK_FILE}
	flock -n 933 || {
		# bring back to original log
		http_response "$ACTION"
		exit 1
	}
}
# 解锁
unset_lock(){
	flock -u 933
	rm -rf ${LOCK_FILE}
}
# 自启链接
fun_nat_start(){
	if [ "${openlist_enable}" == "1" ];then
		if [ ! -L "/jffs/softcenter/init.d/N99openlist.sh" ];then
			echo_date "添加nat-start触发"
			ln -sf /jffs/softcenter/scripts/openlist_config.sh /jffs/softcenter/init.d/N99openlist.sh
# 			ln -sf /jffs/softcenter/scripts/openlist_config.sh /jffs/softcenter/init.d/S99openlist.sh
		fi
	else
		if [ -L "/jffs/softcenter/init.d/N99openlist.sh" ];then
			echo_date "删除nat-start触发"
			rm -f /jffs/softcenter/init.d/?99openlist.sh
		fi
	fi
}
# 进程监控
del_crontab(){
	if [ -n "$(cru l | grep -w openlist_monitor)" ];then
		echo_date "删除定时任务"
		cru d openlist_monitor
	fi
}
fun_crontab(){
	if [ "${openlist_enable}" != "1" ] || [ "${openlist_watchdog_time}" == "" ];then
		del_crontab
		return
	fi
	cru a openlist_monitor "*/${openlist_watchdog_time} * * * * pidof openlist >/dev/null || /jffs/softcenter/scripts/openlist_config.sh quick_start"
	echo_date "创建定时任务，每 ${openlist_watchdog_time} 分钟检查进程"
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
	local IPTS=$(iptables -t filter -S INPUT | grep -w 'openlist_rule')
	local IPTS6=$(ip6tables -t filter -S INPUT | grep -w 'openlist_rule')
	[ -z "${IPTS}" ] && [ -z "${IPTS6}" ] && return
	local tmp_file=/tmp/Clean_openlist_$$
	echo_date "关闭本插件当前打开的所有端口"
	[ -n "${IPTS}" ] && echo "${IPTS}" | sed 's/-A/iptables -D/g' > ${tmp_file}
	[ -n "${IPTS6}" ] && echo "${IPTS6}" | sed 's/-A/ip6tables -D/g' >> ${tmp_file}
	chmod +x ${tmp_file}
	/bin/sh ${tmp_file} >/dev/null 2>&1
	rm ${tmp_file}
}
# 打开端口
open_port(){
if [ "${openlist_publicswitch}" == "1" ] && [ "${openlist_open_port}" == "1" ]; then
	load_xt_comment
	
	local port t_port
	local ports=$PORT
	[ "$ftp_enable" == "true" ] && ports="$ports $ftp_port"
	[ "$sftp_enable" == "true" ] && ports="$ports $sftp_port"
	[ "${s3_enable}" == "true" ] && ports="$ports ${s3_port}"
	for port in $ports
	do
	[ "$port" -gt 65535 -o "$port" -lt 1 ] && continue
	iptables -I INPUT -p tcp --dport ${port} -m comment --comment "openlist_rule" -j ACCEPT >/dev/null 2>&1
	ip6tables -I INPUT -p tcp --dport ${port} -m comment --comment "openlist_rule" -j ACCEPT >/dev/null 2>&1
	[ -n "${t_port}" ] && t_port="${t_port} "
	t_port="${t_port}${port}"
	done
	
	echo_date "打开IPv4/IPv6 TCP端口：${t_port}"
fi
}
# 关闭进程（先常规，再使用信号9强制）
stop_process(){
	local PID=$(pidof openlist)
	if [ -n "${PID}" ];then
		echo_date "停止当前 openlist 主进程"
		start-stop-daemon -K -p ${PID_FILE} >/dev/null 2>&1
		sleep 1 && kill -9 "${PID}" >/dev/null 2>&1
	fi
	rm -f ${PID_FILE}
}
# 停止服务
stop_service() {
	stop_process
	fun_nat_start
	close_port
	del_crontab
}
# 配置文件处理
makeConfig() {
	if [ ! -f "${DATA}/config.json" ]; then
		echo_date "首次启动，初始化配置中...耐心等待"
		echo_date "---------------------------------"
		$PROG server --data $DATA >>${LOG_FILE} 2>&1 &
		local i=28
		until [ -f "${DATA}/config.json" -a -f "${DATA}/data.db" ]; do
			sleep 2
			i=$(($i - 1))
			[ "$i" -lt 1 ] && cfgFail=1 && break
		done
		sleep 2 && killall openlist >/dev/null 2>&1
		sleep 1 && kill -9 $(pidof openlist) >/dev/null 2>&1
		echo_date "---------------------------------"
		[ "$cfgFail" == "1" ] && {
			echo_date "openlist初始化失败，请检查你的配置！"
			return 1
		}
		echo_date "初始化完成，即将应用配置并启动openlist"
		firstPWD=$(grep 'password' ${LOG_FILE} |grep 'admin' | awk '{print $NF}')
	fi

	echo_date "正在处理openlist配置文件：${DATA}/config.json"

	[ -z "$(which jq)" ] && {
		echo_date "找不到依赖软件 jq ，无法继续，通常 SWRT 软件中心默认安装，请修复。"
		cfgFail=1
		return 1
	}

	jq \
	--arg site_url "$site_url" \
	--arg cdn "$cdn" \
	--arg token_expires_in "$token_expires_in" \
	--arg address "$address" \
	--arg http_port "$http_port" \
	--arg https_port "$https_port" \
	--arg cert_file "$cert_file" \
	--arg key_file "$key_file" \
	--arg temp_dir "$temp_dir" \
	--argjson tls_insecure_skip_verify "$tls_insecure_skip_verify" \
	--argjson log_enable "$log_enable" \
	--arg log_name "$log_name" \
	--arg delayed_start "$delayed_start" \
	--arg max_connections "$max_connections" \
	--argjson ftp_enable "$ftp_enable" \
	--arg ftp_listen ":$ftp_port" \
	--argjson sftp_enable "$sftp_enable" \
	--arg sftp_listen ":$sftp_port" \
	--argjson s3_enable "$s3_enable" \
	--arg s3_port "$s3_port" \
	--argjson s3_ssl "$s3_ssl" \
	'
	  .site_url = $site_url
	| .cdn = $cdn
	| .token_expires_in = ($token_expires_in | tonumber)
	| .scheme.address = $address
	| .scheme.http_port = ($http_port | tonumber)
	| .scheme.https_port = ($https_port | tonumber)
	| .scheme.cert_file = $cert_file
	| .scheme.key_file = $key_file
	| .temp_dir = $temp_dir
	| .tls_insecure_skip_verify = $tls_insecure_skip_verify
	| .log.enable = $log_enable
	| .log.name = $log_name
	| .delayed_start = ($delayed_start | tonumber)
	| .max_connections = ($max_connections | tonumber)
	| .ftp.enable = $ftp_enable
	| .ftp.listen = $ftp_listen
	| .sftp.enable = $sftp_enable
	| .sftp.listen = $sftp_listen
	| .s3.enable = $s3_enable
	| .s3.port = ($s3_port | tonumber)
	| .s3.ssl = $s3_ssl
	' \
	"${DATA}/config.json" >/tmp/openlist_$$.json && mv -f /tmp/openlist_$$.json "${DATA}/config.json"
}
# 开启进程
start_process(){
	echo_date "准备启动 openlist ..."
	
	# 符号链接用于网页上读取运行日志。当运行日志和标准输出重定向为同一文件，启动时用>>而非>，避免丢日志
	# 启动时sh -c执行的命令前加exec，使父进程/bin/sh被子进程openlist替换，以免pid不一样出现异常
	if [ "$log_enable" == "true" ]; then
		[ "$openlist_log_std_only" != "1" ] && ln -sf $log_name $RUN_LOG_link || ln -sf /tmp/openlist_std.log $RUN_LOG_link
		true >$RUN_LOG_link
		start-stop-daemon -S -q -b -m -p ${PID_FILE} -a /bin/sh -- -c "exec $PROG server --data $DATA >>$RUN_LOG_link 2>&1"
	else
		start-stop-daemon -S -q -b -m -p ${PID_FILE} -a /bin/sh -- -c "exec $PROG server --data $DATA"
		rm -f $RUN_LOG_link
	fi

	local PID
	local i=50
	until [ -n "${PID}" ]; do
		sleep 1
		i=$(($i - 1))
		PID=$(pidof openlist)
		[ "$i" -lt 1 ] && {
			echo_date "openlist进程启动失败，请检查你的配置！"
			return 1
		}
	done
	echo_date "openlist启动成功，pid：${PID}"
}
write_ver(){
	local filesize=$(ls -lL "$PROG" |awk '{print $5}')
	[ "$openlist_binBytes" == "$filesize" ] && return || dbus set openlist_binBytes=$filesize 

	echo_date "登记主程序版本信息..."
	local VER=$("$PROG" version)
	[ -n "$VER" ] || sleep 2
	local BIN_VER=$(echo "$VER" | grep -w "^Version" | awk '{print $2}')
	local WEB_VER=$(echo "$VER" | grep -w "^WebVersion" | awk '{print $2}')
	if [ -n "${BIN_VER}" -a -n "${WEB_VER}" ]; then
		[ "$openlist_binver" != "${BIN_VER}" ] && dbus set openlist_binver=${BIN_VER}
		[ "$openlist_webver" != "${WEB_VER}" ] && dbus set openlist_webver=${WEB_VER}
	fi
}
# 检测
check_tips(){
	# 内存检测
	local swap_size=$(free | grep Swap | awk '{print $2}')
	if [ "$swap_size" != "0" ];then
		echo_date "当前系统已经启用虚拟内存！容量：$(expr $swap_size \/ 1024) MB"
	else
		local memory_size=$(free | grep Mem | awk '{print $2}')
		if [ "$memory_size" != "0" ];then
			if [  $memory_size -le 750000 ];then
				echo_date "检测到系统内存约：$(expr $memory_size \/ 1024) MB，建议挂载1GB及以上虚拟内存后重启插件！"
			fi
		else
			echo_date "未查询到系统内存，请自行注意系统内存！"
		fi
	fi
	# 证书提示
	[ "$openlist_https" == "1" ] && {
		echo_date "提示：若https证书配置错误，将导致进程终止，可查询运行日志确认"
		[ -n "$openlist_cert_file" -o -n "$openlist_key_file" ] && echo_date "常见证书错误：路径错误找不到文件，或公钥与私钥不匹配"
	}
	
	# 网站URL，可能导致“访问面板”按钮出错
	[ -z "${site_url}" ] && return
	local MATCH_1=$(echo "${site_url}" | grep -Eo "^https://")
	local MATCH_2=$(echo "${site_url}" | grep -Eo "^http://")
	local MATCH_3=$(echo "${site_url}" | grep -Eo ":${PORT}$")
	if [ -n "${MATCH_1}" -a "$openlist_https" != "1" ]; then
		echo_date "网站URL格式为 https ，但当前openlist配置为 http ，可能导致链接错误！"
		dbus set openlist_url_error=1   #标记用于网页确定面板地址
	elif [ -n "${MATCH_2}" -a "${openlist_https}" == "1" ]; then
		echo_date "网站URL格式为 http ，但当前openlist配置为 https ，可能导致链接错误！"
		dbus set openlist_url_error=1
	fi
	if [ -z "${MATCH_3}" ]; then
		echo_date "网站URL端口配置可能错误，或者端口号后面还有不必要字符（比如 /）"
		echo_date "网站URL未正确配置端口：${PORT}，可能出现导航链接错误等异常！"
		dbus set openlist_url_error=1
	fi
}

# 开启服务
start_service() {
	[ "${openlist_enable}" != "1" ] && {
		stop_service
		echo_date "openlist 被禁用"
		return
	}

	#删除url错误标记
	dbus remove openlist_url_error

	# 停止旧进程
	stop_process

	#检查二进制
	[ -f "$PROG" ] || {
		echo_date "设置的【主程序路径】，找不到文件！请修正。" 
		dbus remove openlist_binBytes
		dbus remove openlist_binver
		dbus remove openlist_webver
		return 1
	}
	[ -x "$PROG" ] || chmod 0755 "$PROG"

	# 检测信息
	check_tips

	# 准备配置
	makeConfig
	[ "$cfgFail" == "1" ] && return 1

	# 登记版本
	write_ver

	# 启动进程
	start_process

	# 打开端口
	close_port
	open_port

	# 进程监控
	fun_crontab

	# 自启动
	fun_nat_start

	[ -n "$firstPWD" ] && echo_date "---->注意：用户 admin 初始密码为 $firstPWD"
}

# 重置密码
random_password(){
	echo_date "重新生成openlist面板的随机密码..."
	echo_date "---------------------------------"
	$PROG --data $DATA admin random >>${LOG_FILE} 2>&1
	sleep 2
	local USER=$(cat ${LOG_FILE} | grep "username:" | awk '{print $NF}')
	local PASS=$(cat ${LOG_FILE} | grep "password:" | awk '{print $NF}')
	if [ -n "${USER}" -a -n "${PASS}" ]; then
		echo_date "---------------------------------"
		echo_date "openlist面板用户：${USER}"
		echo_date "openlist面板密码：${PASS}"
	else
		echo_date "---------------------------------"
		echo_date "密码似乎未查到！请自行检查本输出框！"
	fi
}
# 若用户配置文件设置了延迟启动，猜测其遇到启动问题，酌情延迟本脚本启动（开机180s内最多30s）
isDelay(){
	[ "$delayed_start" -le "0" ] && return
	[ -e /proc/uptime ] && [ $(awk -F. '{print $1}' /proc/uptime) -gt "180" ] && return
	[ "$delayed_start" -gt "30" ] && sleep 30 || sleep $delayed_start
}

case $1 in
start)
	[ "${openlist_enable}" != "1" ] && exit
	isDelay
	logger "[软件中心]: OpenList启动中。"
	true >${LOG_FILE}
	start_service | tee -a ${LOG_FILE}
	echo XU6J03M16 >>${LOG_FILE}
	;;
quick_start)
	[ -n "$(pidof openlist)" ] && exit
	start_process | tee -a ${LOG_FILE}
	;;
start_nat)
	sleep 3
	{
	if [ -z "$(pidof openlist)" ] || [ "$address" != "0.0.0.0" ]; then
		isDelay
		echo_date "[软件中心]：openlist启动..."
		logger "[软件中心]：openlist启动..."
		start_service
	else
		echo_date "[软件中心]：openlist检查防火墙端口"
		close_port
		open_port
	fi
	} | tee -a $LOG_FILE
	echo XU6J03M16 >>${LOG_FILE}
	;;
stop)
	stop_service
	;;
restart)
	stop_service
	start_service
	;;
esac

case $2 in
web_submit)
	set_lock
	true > ${LOG_FILE}
	http_response "$1"
	echo_date "开启openlist！" | tee -a ${LOG_FILE}
	start_service | tee -a ${LOG_FILE}
	echo XU6J03M16 >>${LOG_FILE}
	unset_lock
	;;
resetpwd)
	set_lock
	true >${LOG_FILE}
	random_password | tee -a ${LOG_FILE}
	echo XU6J03M16 >>${LOG_FILE}
	unset_lock
	;;
esac
