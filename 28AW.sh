#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
"$DIR"/nextBus.sh -s 5001547 -t 1 -d Tysons -r 28A "$@"

