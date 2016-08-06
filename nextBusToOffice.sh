#!/bin/bash

tookBusTime=$(tail -1 "$HOME/logs/tookBusTime.log")
[ $(date +%s) -lt $(($tookBusTime + 3600)) ] && exit 0

nextBusToOffice=$($HOME/dev/NextBus/3T.sh -e "$@")
[ -z "$nextBusToOffice" ] && { echo "没有收到下趟车的信息"; exit 0; }

_echo_if_in_range() {
    [[ "$1" -le 10 && "$1" -ge 4 ]] && { echo "下趟车还有${1}分钟就要到了"; exit 0; }
}

first=$(echo "$nextBusToOffice" | awk '{print $1}')
_echo_if_in_range $first

second=$(echo "$nextBusToOffice" | awk '{print $2}')
[ -z "$second" ] || _echo_if_in_range $second
