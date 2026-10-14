#!/bin/sh
source /jffs/softcenter/scripts/base.sh
alias echo_date='echo [$(TZ=UTC-8 date "+%Y-%m-%d %H:%M:%S")]:'

eval "$(dbus export gostun_)"

LOG_FILE="/tmp/upload/gostun_log.txt"
PID_FILE="/tmp/gostun_detect.pid"

run_detect() {
	mkdir -p /tmp/upload
	: >"${LOG_FILE}"

	if [ -f "${PID_FILE}" ]; then
		OLD_PID="$(cat "${PID_FILE}" 2>/dev/null)"
		if [ -n "${OLD_PID}" ] && kill -0 "${OLD_PID}" >/dev/null 2>&1; then
			kill "${OLD_PID}" >/dev/null 2>&1
		fi
		rm -f "${PID_FILE}"
	fi

	dbus set gostun_running="1"

	(
		echo_date "➡️ Gostun NAT检测开始..."

		REMOVED_FORWARD_DROP="0"
		REMOVED_INPUT_DROP="0"
		FW_ADJUSTED="0"
		WAN_NAT_TYPE=""
		LAN_NAT_TYPE=""
		WAN_CONE_LEVEL="0"
		LAN_CONE_LEVEL="0"
		LAN_NEED_HINT="0"

		restore_fw_rules() {
			if [ "${REMOVED_INPUT_DROP}" = "1" ]; then
				iptables -t filter -A INPUT -j DROP >/dev/null 2>&1
			fi
			if [ "${REMOVED_FORWARD_DROP}" = "1" ]; then
				iptables -t filter -A FORWARD -j DROP >/dev/null 2>&1
			fi
			if [ "${FW_ADJUSTED}" = "1" ]; then
				echo_date "🔚 检测结束，恢复防火墙规则！"
			else
				echo_date "🔚 检测结束！"
			fi
			# if [ "${WAN_CONE_LEVEL}" = "1" ]; then
			# 	echo_date "🎉 恭喜，检测到你的WAN侧网络类型是Full Cone，即NAT1！"
			# fi
			local ppp_if=$(iptables -t nat -S POSTROUTING 2>/dev/null | grep -Eo "ppp[0-9]" | head -n 1)
			if [ "${LAN_NEED_HINT}" = "1" ]; then
				echo_date "🎉 漂亮，检测到你的 WAN 侧网络类型是：Full Cone，即NAT1！"
				echo_date "⚠️ 检测到LAN侧网络类型是：${LAN_NAT_TYPE}，即NAT${LAN_CONE_LEVEL}，与WAN侧网络NAT类型不一致！！"
				echo_date "🚀 如需改善局域网LAN网络NAT类型到 Full Cone，可以前往 外部网络(WAN) 修改 NAT类型 为 全锥形(FULLCONE)！"
			elif [ "${LAN_NEED_HINT}" = "2" ]; then
				echo_date "🎉 漂亮，检测到你的 WAN 侧网络类型是：Full Cone，即NAT1！"
				echo_date "🎉 漂亮，检测到你的 LAN 侧网络类型是：Full Cone，即NAT1！"
				echo_date "🎉 恭喜，你的网络环境基本无限制，上网冲浪、看视频、玩游戏等更顺畅，下载速度更快更稳！"
			elif [ "${LAN_NEED_HINT}" = "3" ]; then
				echo_date "🥹 哦豁，检测到你的 WAN 侧网络类型是：Port Restricted Cone，即NAT3"
				if [ -z ${ppp_if} ];then
					echo_date "⚠️ 通过改光猫桥接后路由器拨号上网通常可以改善WAN侧的NAT类型。"
				else
					echo_date "⚠️ 可以反馈给网络运营商，看是否存在isp局端限制。"
				fi
			elif [ "${LAN_NEED_HINT}" = "4" ]; then
				echo_date "😭 哦豁，检测到你的 WAN 侧网络类型是：Symmetric，即NAT4，最严格最糟糕的那种网络。"
				if [ -z ${ppp_if} ];then
					echo_date "⚠️ 如果你是企事业单位/高校等内网环境，那也别想优化了。"
					echo_date "⚠️ 如果是家庭带宽，请检查下是否在多层NAT之下，尝试将本路由作为主路由拨号使用。"
				else
					echo_date "⚠️ 作为家庭带宽，基本就告别主机游戏联机，迅雷下载了，微信在你这里都可能经常转圈，甚至刷抖音都会间歇性卡顿。"
					echo_date "⚠️ 也许运营商给你做了限制，建议及时联系运营商，甚至前往工信部投诉，以期改善。"
				fi
			elif [ "${LAN_NEED_HINT}" = "5" ]; then
				echo_date "⚠️ 检测到你的 WAN 侧网络类型是：Restricted Cone，即NAT2！"
				echo_date "⚠️ 这种类型的nat不多见，请检查你的网络结构，看是否存在优化空间！"

			
			elif [ "${LAN_NEED_HINT}" = "6" ]; then
				echo_date "⚠️ WAN侧网络检测出现问题，可能是高峰期/udp丢包等造成，请重试检测！！"
			fi
			echo "XU6J03M6"
			dbus set gostun_running="0"
			if [ -f "${PID_FILE}" ] && [ "$(cat "${PID_FILE}" 2>/dev/null)" = "$$" ]; then
				rm -f "${PID_FILE}"
			fi
		}
		trap restore_fw_rules EXIT
		echo $$ >"${PID_FILE}"

		if [ ! -x "/jffs/softcenter/bin/gostun" ]; then
			echo_date "⚠️ 错误：未找到 /jffs/softcenter/bin/gostun"
			exit 0
		fi

		if [ -z "${gostun_server}" ] || [ "${gostun_server}" = "null" ]; then
			gostun_server="auto"
			dbus set gostun_server="${gostun_server}"
		fi
		if [ -z "${gostun_custom}" ] || [ "${gostun_custom}" = "null" ]; then
			gostun_custom=""
			dbus set gostun_custom=""
		fi

		dbus set gostun_last_run="$(date +%Y-%m-%d_%H:%M:%S)"

		if iptables -t filter -S 2>/dev/null | grep -q -e "-A INPUT -j DROP"; then
			if iptables -t filter -D INPUT -j DROP >/dev/null 2>&1; then
				REMOVED_INPUT_DROP="1"
				FW_ADJUSTED="1"
			fi
		fi

		if iptables -t filter -S 2>/dev/null | grep -q -e "-A FORWARD -j DROP"; then
			if iptables -t filter -D FORWARD -j DROP >/dev/null 2>&1; then
				REMOVED_FORWARD_DROP="1"
				FW_ADJUSTED="1"
			fi
		fi

		if [ "${FW_ADJUSTED}" = "1" ]; then
			echo_date "🧱 调整防火墙规则，以保证检测准确性"
		fi

		server=""
		LAST_NAT_TYPE=""
		LAST_GOSTUN_RET="0"
		run_gostun_block() {
			label="$1"
			shift
			TMP_GOSTUN_OUT="/tmp/gostun_out_$$.txt"
			: >"${TMP_GOSTUN_OUT}"
			echo_date "------------------------- gostun 输出开始（${label}） -------------------------"
			/jffs/softcenter/bin/gostun "$@" >"${TMP_GOSTUN_OUT}" 2>&1
			LAST_GOSTUN_RET=$?
			LAST_NAT_TYPE="$(awk -F': ' '/NAT Type/ {print $2}' "${TMP_GOSTUN_OUT}" | head -n 1)"
			sed "s/^/[$(TZ=UTC-8 date "+%Y-%m\-%d %H:%M:%S")]: 📝 /" "${TMP_GOSTUN_OUT}"

			rm -f "${TMP_GOSTUN_OUT}"
			echo_date "------------------------- gostun 输出结束（${label}） -------------------------"
			return 0
		}

		find_wan_iface() {
			wan_if=$(iptables -t nat -S POSTROUTING 2>/dev/null | grep -Eo "ppp[0-9]" | head -n 1)
			if [ -n "${wan_if}" ]; then
				echo "${wan_if}"
				return 0
			fi
			wan_if=$(iptables -t nat -S POSTROUTING 2>/dev/null | grep -Eo "eth[0-9]" | head -n 1)
			if [ -n "${wan_if}" ]; then
				echo "${wan_if}"
				return 0
			fi
			wan_if=$(iptables -t nat -S POSTROUTING 2>/dev/null | grep -Eo "wan[0-9]" | head -n 1)
			if [ -n "${wan_if}" ]; then
				echo "${wan_if}"
				return 0
			fi
			echo ""
			return 0
		}

		if [ -z "${gostun_server}" ] || [ "${gostun_server}" = "auto" ]; then
			server="auto"
		elif [ "${gostun_server}" = "custom" ]; then
			server="${gostun_custom}"
			if [ -z "${server}" ]; then
				echo_date "⚠️错误：自定义STUN服务器不能为空！"
				exit 0
			fi
			echo_date "✳️ STUN服务器：${server}"
		else
			server="${gostun_server}"
			echo_date "✳️ STUN服务器：${server}"
		fi

		#echo_date ""
		echo
		echo_date "🧪 开始测试NAT前网络（WAN侧）..."
		WAN_IF="$(find_wan_iface)"
		if [ -n "${WAN_IF}" ]; then
			echo_date "🌏️ WAN侧（NAT前）测试出口：${WAN_IF}"
			if [ "${server}" = "auto" ]; then
				run_gostun_block "WAN侧（NAT前）" -type ipv4 -timeout 3 -interface "${WAN_IF}"
			else
				run_gostun_block "WAN侧（NAT前）" -type ipv4 -timeout 3 -interface "${WAN_IF}" -server "${server}"
			fi
		else
			echo_date "🌏️ WAN侧（NAT前）测试出口：自动（未识别到 pppX/ethX/wanX）"
			if [ "${server}" = "auto" ]; then
				run_gostun_block "WAN侧（NAT前）" -type ipv4 -timeout 3
			else
				run_gostun_block "WAN侧（NAT前）" -type ipv4 -timeout 3 -server "${server}"
			fi
		fi
		WAN_NAT_TYPE="${LAST_NAT_TYPE}"
		echo_date "🌏️ WAN侧（NAT前）NAT类型：${WAN_NAT_TYPE}"
		#echo_date ""
		echo
		if [ "${WAN_NAT_TYPE}" = "Full Cone" ]; then
			WAN_CONE_LEVEL="1"
		elif [ "${WAN_NAT_TYPE}" = "Restricted Cone" ]; then
			WAN_CONE_LEVEL="2"
		elif [ "${WAN_NAT_TYPE}" = "Port Restricted Cone" ]; then
			WAN_CONE_LEVEL="3"
		elif [ "${WAN_NAT_TYPE}" = "Symmetric" ]; then
			WAN_CONE_LEVEL="4"
		fi

		echo_date "🧪 开始测试NAT后网络（LAN侧）..."
		echo_date "💻️ LAN侧（NAT后）测试出口：br0"
		if [ "${server}" = "auto" ]; then
			run_gostun_block "LAN侧（NAT后）" -type ipv4 -timeout 3 -interface br0
		else
			run_gostun_block "LAN侧（NAT后）" -type ipv4 -timeout 3 -interface br0 -server "${server}"
		fi
		LAN_NAT_TYPE="${LAST_NAT_TYPE}"
		echo_date "💻️ LAN侧（NAT后）NAT类型：${LAN_NAT_TYPE}"
		echo ""

		if [ "${LAN_NAT_TYPE}" = "Full Cone" ]; then
			LAN_CONE_LEVEL="1"
		elif [ "${LAN_NAT_TYPE}" = "Restricted Cone" ]; then
			LAN_CONE_LEVEL="2"
		elif [ "${LAN_NAT_TYPE}" = "Port Restricted Cone" ]; then
			LAN_CONE_LEVEL="3"
		elif [ "${LAN_NAT_TYPE}" = "Symmetric" ]; then
			LAN_CONE_LEVEL="4"
		fi

		if [ -n "${WAN_CONE_LEVEL}" ]; then
			dbus set fullcone_wan_nattype="NAT${WAN_CONE_LEVEL}"
		else
			dbus remove fullcone_wan_nattype >/dev/null 2>&1
		fi
		if [ -n "${LAN_CONE_LEVEL}" ]; then
			dbus set fullcone_lan_nattype="NAT${LAN_CONE_LEVEL}"
		else
			dbus remove fullcone_lan_nattype >/dev/null 2>&1
		fi

		if [ "${WAN_NAT_TYPE}" = "Full Cone" ] && { [ "${LAN_NAT_TYPE}" = "Restricted Cone" ] || [ "${LAN_NAT_TYPE}" = "Port Restricted Cone" ] || [ "${LAN_NAT_TYPE}" = "Symmetric" ]; }; then
			LAN_NEED_HINT="1"
		fi

		if [ "${WAN_NAT_TYPE}" = "Full Cone" ] && [ "${LAN_NAT_TYPE}" = "Full Cone" ]; then
			LAN_NEED_HINT="2"
		fi

		if [ "${WAN_NAT_TYPE}" = "Port Restricted Cone" ]; then
			LAN_NEED_HINT="3"
		fi

		if [ "${WAN_NAT_TYPE}" = "Symmetric" ]; then
			LAN_NEED_HINT="4"
		fi

		if [ "${WAN_NAT_TYPE}" = "Restricted Cone" ]; then
			LAN_NEED_HINT="5"
		fi

		if [ "${WAN_NAT_TYPE}" = "endpoint independent (no NAT)[NatMappingBehavior] address dependent[NatFilteringBehavior]" ]; then
			LAN_NEED_HINT="6"
		fi
	) >>"${LOG_FILE}" 2>&1 &
}

case "$2" in
1)
	run_detect
	;;
2)
	mkdir -p /tmp/upload
	echo "" >"${LOG_FILE}"
	echo "XU6J03M6" >>"${LOG_FILE}"
	rm -f "${PID_FILE}"
	dbus set gostun_running="0"
	;;
*)
	;;
esac

http_response "$1"
