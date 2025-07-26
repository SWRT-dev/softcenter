#!/bin/sh

source /jffs/softcenter/scripts/base.sh
conf=/tmp/speedtest/settings.toml
killall speedtest

case $ACTION in
start)
	mkdir -p /tmp/speedtest
	cat > $conf <<-EOF
	bind_address=""
	listen_port=8989
	proxyprotocol_port=0
	server_lat=1
	server_lng=1
	ipinfo_api_key=""
	assets_path=""
	redact_ip_addresses=false
	database_type="none"
	database_hostname=""
	database_name=""
	database_username=""
	database_password=""
	database_file="speedtest.db"
	EOF
	killall -9 speedtest
	/jffs/softcenter/bin/speedtest -c $conf &
	http_response "$1"
	;;
stop)
	killall -9 speedtest
	rm -f $conf
	http_response "$1"
	;;
esac
