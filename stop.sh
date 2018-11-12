#!/bin/bash

#npm is automatically killed when exiting the script, so we need to kill everything else:

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

kill $(ps aux | grep $DIR | awk '{print $2}')
