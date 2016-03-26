#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# PIMMIT DR + FAIRFAX TOWERS
"$DIR"/nextBus.sh -s 5001507 -t 10 -d Mclean -r 3T "$@"

