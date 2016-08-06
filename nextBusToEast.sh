#!/bin/bash

set -e
tookBusTime=$(tail -1 "$HOME/logs/tookBusTime.log")
[ $(date +%s) -lt $(($tookBusTime + 3600)) ] && exit 0

nextBusToEast=$($HOME/dev/NextBus/3THomeEast.sh -e "$@")
[ -z "$nextBusToEast" ] && { echo "没有收到下趟车的信息" ; exit 0; }

_echo_if_in_range() {
    [[ "$1" -le 15 && "$1" -ge 4 ]] && { echo "下趟车还有${1}分钟就要到了" ; exit 0; }
}

first=$(echo "$nextBusToEast" | awk '{print $1}')
_echo_if_in_range $first

second=$(echo "$nextBusToEast" | awk '{print $2}')
[ -z "$second" ] || _echo_if_in_range $second
