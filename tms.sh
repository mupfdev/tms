#! /bin/bash
# T orified M essage S ervice.
# Sends your SMS through TOR using the SMS-Expert gateway.
# https://www.sms-expert.de/pdf/SMS-Gateway_HTTP(S)_API.pdf
#
# Author: Michael Fitzmayer <mail@michael-fitzmayer.de>
#
# This script is free and unencumbered software released into the public
# domain.  See the file LICENSE for details.

# Configuration.
USERNAME="johndoe"
GWPASSWD="foobar"

die () {
    echo >&2 "$@"
    exit 1
}

urlencode() {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c"
        esac
    done
}

if [ $# -ge 3 ]
then
    echo $2 | grep -E -q '^[0-9]+$' || die "receiver: numeric argument required."
    HASH=`echo -n "$USERNAME|$GWPASSWD|expert|$1|$2|$3|" | md5sum - | cut -c 1-32`
    MESSAGE=`urlencode "$3"`
    curl --silent --ipv4 --socks5-hostname 127.0.0.1:9050 --get "https://gateway.sms-expert.de/send/?user=$USERNAME&type=expert&sender=$1&receiver=$2&message=$MESSAGE&hash=$HASH" | sed -n 's:.*<statusText>\(.*\)</statusText>.*:\1:p'
else
    echo -e "\e[1m\e[32mT\e[0morified \e[1m\e[32mM\e[0message \e[1m\e[32mS\e[0mervice"
    echo
    echo "Usage: $0 <sender> <receiver> <message>"
    echo
    echo "Examples:"
    echo "$0 49157890123456 49157890123456 \"Hey there\!\""
    echo "$0 NSA 49157890123456 \"Big brother is watching you.\""
fi
