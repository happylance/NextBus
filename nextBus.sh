#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
key_file="$DIR/.wmata_key"
[ -e "$key_file" ] || exit

can_show_pop_up=false
show_debug_info=false
exit_immediately=false
verbose=false
while getopts s:t:d:r:piev opt; do
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
        e)
            exit_immediately=true;;
        v)
            verbose=true;;
        ?)
            exit 5;
    esac
done

$verbose && set -x

wmata_key=$(cat $DIR/.wmata_key)

_restore_cursor () {
    [ -t 0 ] && stty sane
    tput cnorm
}
_show_pop_up() {
    message="Next $route is in $1 minutes"
    if $can_show_pop_up; then
        osascript << EOF &>/dev/null
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
    $exit_immediately && exit 0
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
    if ! $exit_immediately; then
        # Do not echo input from stdin
        tput civis # Hide cursor
        [ -t 0 ] && stty -echo -icanon -icrnl time 0 min 0
        # Handle ctrl-c and ctrl-z gracefully.
        trap "_stop" SIGINT
        trap "" SIGTSTP   
    fi

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
        $exit_immediately && exit 0
        [ ${predictions[0]} -le $2 ] && [ ${predictions[0]} -ge $(($2 - 5)) ] && _show_pop_up ${predictions[0]} && _stop
        sleep 20
    done
}

next_bus $stop_id $alert_time "$destination"

