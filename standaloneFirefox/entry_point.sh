#!/bin/bash

source /opt/selion/functions.sh

export GEOMETRY="$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"

function shutdown {
  kill -s SIGTERM $NODE_PID
  wait $NODE_PID
}

if [ ! -z "$SELION_OPTS" ]; then
  echo "appending SeLion options: ${SELION_OPTS}"
fi

SERVERNUM=$(get_server_num)
xvfb-run -n $SERVERNUM --server-args="-screen 0 $GEOMETRY -ac +extension RANDR" \
  java -DselionHome=$SELION_HOME -jar $SELION_HOME/SeLion-Grid.jar \
  ${SELION_OPTS} &
NODE_PID=$!

trap shutdown SIGTERM SIGINT
wait $NODE_PID
