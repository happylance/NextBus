#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
key_file="$DIR/.wmata_key"
[ -e "$key_file" ] || exit

can_show_pop_up=true
if [ "$4" == "-s" ]; then
    can_show_pop_up=false
fi

wmata_key=$(cat $DIR/.wmata_key)
_show_pop_up() {
    if $can_show_pop_up; then
        osascript -e 'display dialog "Your next bus will be ready soon."' &>/dev/null
    else
        echo "Your next bus will be ready in $1 minutes"
        exit 0
    fi
}

_stop(){
    [ -t 0 ] && stty sane
    tput cnorm
    exit
}

predictions=''
_next_bus () {
    stop_id=$1
    url=https://api.wmata.com/NextBusService.svc/json/jPredictions\?StopID\=$stop_id\&api_key\=$wmata_key
    predictions=($(curl -s $url | python -m json.tool | sed -n "/\"DirectionText\":.*$2/,/Minutes/p" | grep "Minutes" | sed 's/.*Minutes": \([0-9]*\),.*/\1/'))
}

next_bus () {
    tput civis # Hide cursor

    # Do not echo input from stdin
    [ -t 0 ] && stty -echo -icanon -icrnl time 0 min 0
    # Handle ctrl-c and ctrl-z gracefully.
    trap "_stop" SIGINT
    trap "" SIGTSTP   


    while true; do
        _next_bus $1 "$3"
        count=${#predictions[@]} 
        [ $count -gt 0 ] || _stop
        output=${predictions[0]}
        [ $count -gt 1 ] && output="$output ${predictions[1]}"
        if $can_show_pop_up; then
            echo -ne "$output   \r"
        else
            echo "$output"
        fi
        [ ${predictions[0]} -le $2 ] && [ ${predictions[0]} -ge $(($2 - 5)) ] && _show_pop_up ${predictions[0]} && _stop
        sleep 20
    done
}

next_bus $1 $2 "$3"

