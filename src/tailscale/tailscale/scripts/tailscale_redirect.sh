#!/bin/sh

add_forward(){
	local info_if
	while [ -z "$info_if" ]
	do
		sleep 1s
		info_if=$(ifconfig |grep tailscale | awk '{print $1}')
	done
	iptables -D FORWARD -i br0 -o tailscale0 -j ACCEPT >/dev/null 2>&1
	iptables -t nat -D POSTROUTING -o tailscale0 -j MASQUERADE >/dev/null 2>&1
	iptables -I FORWARD -i br0 -o tailscale0 -j ACCEPT
	iptables -t nat -I POSTROUTING -o tailscale0 -j MASQUERADE
}
add_forward
