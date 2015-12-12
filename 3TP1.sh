#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
"$DIR"/nextBus.sh -s 5004590 -t 1 -d McLean -r 3T "$@"

