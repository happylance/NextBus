#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
"$DIR"/nextBus.sh -s 5004590 -t 10 -d McLean -r 3T "$@"

