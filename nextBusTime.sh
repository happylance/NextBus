#!/bin/bash

tookBusTime=$(tail -1 "$HOME/logs/tookBusTime.log")
[ $(date +%s) -lt $(($tookBusTime + 3600)) ] && exit 0

[ $(date +%p) == "PM" ] && isPM=true
[ $(date +%a) == "Sat" ] && isSat=true

if [ "$isSat" = true ] ; then
    if ["$isPM" = true ]; then
        script="3TP10"
    else
        script="3THomeEast"
    fi
else
    if [ "$isPM" = true ] ; then
        script="goHome"
    else
        script="3T"
    fi
fi

nextBusTime=$($HOME/dev/NextBus/$script.sh -e "$@")
[ -z "$nextBusTime" ] && { echo "没有收到下趟车的信息"; exit 0; }

_echo_if_in_range() {
    [[ "$1" -le 15 ]] && { echo "下趟车还有${1}分钟就要到了"; exit 0; }
}

first=$(echo "$nextBusTime" | awk '{print $1}')
_echo_if_in_range $first
