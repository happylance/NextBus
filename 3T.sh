#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
"$DIR"/nextBus.sh -s 5001970 -t 10 -d Mclean -r 3T "$@"

