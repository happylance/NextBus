#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# PIMMIT DR + FAIRFAX TOWERS
"$DIR"/nextBus.sh -s 5001507 -t 1 -d McLean -r 3T "$@"

