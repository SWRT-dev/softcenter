#!/bin/sh

add_snat(){
	local info_all info_if info_ip info_ip6 info_tmp info_tmp6 info_pip info_pip6
	while [ -z "$info_if" ]
	do
		sleep 1s
		info_if=$(ifconfig |grep tailscale | awk '{print $1}')
	done
	info_all=`/jffs/softcenter/bin/tailscale status --json`
	info_ip=`echo ${info_all} | /jffs/softcenter/bin/jq -r .TailscaleIPs[0]`
	#info_ip6=`echo ${info_all} | /jffs/softcenter/bin/jq -r .TailscaleIPs[0]`
	info_tmp=`echo ${info_all} | /jffs/softcenter/bin/jq -r .Peer.[].TailscaleIPs[0]`
	#info_tmp6=`echo ${info_all} | /jffs/softcenter/bin/jq -r .Peer.[].TailscaleIPs[1]`
	for info_pip in $info_tmp
	do
		iptables -t nat -A POSTROUTING -d $info_pip -p tcp -j SNAT --to $info_ip
		iptables -t nat -A POSTROUTING -d $info_pip -p udp -j SNAT --to $info_ip
	done
#how do it?
#	for info_pip6 in $info_tmp6
#	do
#		ip6tables -t nat -A POSTROUTING -d $info_pip6 -p tcp -j SNAT --to $info_ip6
#		ip6tables -t nat -A POSTROUTING -d $info_pip6 -p udp -j SNAT --to $info_ip6
#	done
}
add_snat
