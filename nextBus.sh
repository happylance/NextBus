#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
key_file="$DIR/.wmata_key"
[ -e "$key_file" ] || exit

can_show_pop_up=false
show_debug_info=false
while getopts s:t:d:r:pi opt; do
    case $opt in
        s) 
            stop_id=$OPTARG;;
        t)
            alert_time=$OPTARG;;
        d) 
            destination=$OPTARG;;
        r)
            route=$OPTARG;;
        p)
            can_show_pop_up=true;;
        i)
            show_debug_info=true;;
        ?)
            exit 5;
    esac
done

wmata_key=$(cat $DIR/.wmata_key)

_restore_cursor () {
    [ -t 0 ] && stty sane
    tput cnorm
}
_show_pop_up() {
    message="Next $route in $1 minutes"
    if $can_show_pop_up; then
        osascript -e << EOF &>/dev/null
        display dialog "$message"
EOF
    else
        echo "$message"
        $show_debug_info && curl -s $url
        _restore_cursor
        exit 0
    fi
}

_stop(){
    _restore_cursor
    $show_debug_info && curl -s $url
    exit 1
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

next_bus $stop_id $alert_time "$destination"

