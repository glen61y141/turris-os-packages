#!/bin/sh
set -e
. /lib/functions.sh

zone_list() {
	local conf="$1"

	local sentinel_log
	config_get_bool sentinel_log "$conf" _sentinel_managed__log "0"
	if [ "$sentinel_log" = "1" ]; then
		local name
		config_get name "$conf" name
		echo "$name"
	fi
}

_set_log() {
	local conf="$1"
	uci -q batch <<-EOT
		set firewall.$conf.log=1
		set firewall.$conf.log_limit=500/sec
	EOT
}

_unset_log() {
	local conf="$1"
	uci -q batch <<-EOT
		delete firewall.$conf.log
		delete firewall.$conf.log_limit
	EOT
}

zone_fix() {
	local conf="$1"

	local sentinel_log
	config_get_bool sentinel_log "$conf" _sentinel_managed__log
	if [ "$sentinel_log" = "1" ]; then
		_set_log "$conf"
	fi
}

zone_on_package_remove() {
	local conf="$1"

	local sentinel_log
	config_get_bool sentinel_log "$conf" _sentinel_managed__log
	if [ "$sentinel_log" = "1" ]; then
		_unset_log "$conf"
	fi
}

zone_enable() {
	local conf="$1"
	local name sentinel_log

	config_get name "$conf" name
	[ "$name" != "$zone_name" ] && return

	uci set "firewall.$conf.log=1"
	_set_log "$conf"
}

zone_disable() {
	local conf="$1"

	local name
	config_get name "$conf" name
	[ "$name" != "$zone_name" ] && return

	local sentinel_log
	config_get_bool sentinel_log "$conf" _sentinel_managed__log
	uci set "firewall.$conf._sentinel_managed__log=0"

	if [ "$sentinel_log" = "1" ]; then
		_unset_log "$conf"
	fi
}

do_zone() {
	local handle="$1"
	local zone_name="${2:-}"
	config_foreach "$handle" zone
}

# Argument parsing and "main" ####################################################

print_usage() {
	echo "Usage:"
	echo "  $0 [-f] [-r] [-e ZONE].. [-d ZONE].."
	echo "  $0 -l"
	echo "  $0 -h"
}

print_help() {
	print_usage
	echo "Options:"
	echo "  -l  List zones with logging enabled"
	echo "  -e  Enable logging on given zone"
	echo "  -d  Disable logging on given zone"
	echo "  -f  Fix firewall logging settings for zones with enabled sentinel logging"
	echo "  -r  Clean configuration on package removal"
	echo "  -h  Print this help text"
}

[ "$#" -gt 0 ] || {
	print_usage
	exit 1
}

config_load firewall

while getopts "lfre:d:h" opt; do
	case "$opt" in
		l)
			do_zone zone_list
			;;
		f)
			do_zone zone_fix
			;;
		r)
			do_zone zone_on_remove
			;;
		e)
			do_zone zone_enable "$OPTARG"
			;;
		d)
			do_zone zone_disable "$OPTARG"
			;;
		h)
			print_help
			exit 0
			;;
		*)
			print_usage
			exit 1
	;;
	esac
done
[ $# != $OPTIND ] || {
	print_usage
	exit 1
}

if [ -n "$(uci changes firewall)" ]; then
	uci commit firewall
	echo "Reloading firewall" >&2
	/etc/init.d/firewall reload
fi
