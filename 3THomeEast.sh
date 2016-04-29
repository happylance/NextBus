#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
"$DIR"/nextBus.sh -s 5001991 -t 10 -d East -r 3T "$@"

