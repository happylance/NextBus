#!/bin/bash
set -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
key_file="$DIR/.wmata_key"
[ -e "$key_file" ] || exit

wmata_key=$(cat $DIR/.wmata_key)
url="https://api.wmata.com/Bus.svc/json/jRouteDetails?RouteID=$1&IncludingVariations=false"
header="api_key:$wmata_key"
if [ -z "$2" ]; then
    curl $url -s -H "$header" | python -m json.tool | grep -e Name -e DirectionText 
else
    curl $url -s -H "$header" | python -m json.tool | grep -e StopID -e Name -e DirectionText | sed -n "/$2/{N;p;};/DirectionText/p"
fi
