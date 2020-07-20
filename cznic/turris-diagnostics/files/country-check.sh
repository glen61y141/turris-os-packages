#!/bin/sh
set -e

COUNTRY_SYSTEM_SET='true'
COUNTRY_WIRELESS_SET='true'

MISSING_COUNTRY_MESSAGE=$(cat <<-EOF
	Your system does not have a country (region) set correctly.
	Please go to Foris interface, make sure you have set correct country in
	the "Region and time" tab and then "Save" your wireless configuration
	in the "Wi-Fi" tab again.
EOF
)


main() {
	# check all wireless wi-fi device sections
	. /lib/functions.sh
	config_load wireless
	config_foreach wireless_section_check_country wifi-device

	# check system configuration (there is always only one section)
	check_country_system

	send_notification
}


wireless_section_check_country() {
	local section_name="$1"

	local disabled
	config_get_bool disabled "$section_name" disabled 0
	[ "$disabled" = '1' ] && {
		return
	}

	local country
	config_get country "$section_name" country
	if [ -z "$country" ]; then
		COUNTRY_WIRELESS_SET='false'
	fi
}


check_country_system() {
	local country
	country="$(uci get -q 'system.@system[0]._country')" || true

	if [ -z "$country" ]; then
		COUNTRY_SYSTEM_SET='false'
	fi
}


send_notification() {
	if [ "$COUNTRY_WIRELESS_SET" = 'false' -o "$COUNTRY_SYSTEM_SET" = 'false' ]; then
		create_notification -s error "$MISSING_COUNTRY_MESSAGE"
	fi
}


main
