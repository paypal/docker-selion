#!/bin/bash

# Assumptions:
# Selion grid files in $SELION_HOME
# $SELION_HOME defined in env
# JAVA available on PATH

CONF=$SELION_HOME/config/hubConfig.json
SELCONF=$SELION_HOME/config/SelionConfig.json

$SELION_HOME/generate_config >$CONF
$SELION_HOME/generate_selionConfig >$SELCONF

echo "starting selenium hub with configuration:"
cat $CONF
cat $SELCONF

function shutdown {
    echo "shutting down hub.."
    kill -s SIGTERM $NODE_PID
    wait $NODE_PID
    echo "shutdown complete"
}

if [ ! -z "$SELION_OPTS" ]; then
  echo "appending SeLion options: ${SELION_OPTS}"
fi

cd $SELION_HOME && java -DselionHome=$SELION_HOME ${JAVA_OPTS} \
  -classpath $SELION_HOME/selenium-server-standalone.jar:$SELION_HOME/SeLion-Grid.jar \
  -jar $SELION_HOME/SeLion-Grid.jar \
  -role hub \
  -hubConfig $CONF \
	-selionConfig $SELCONF \
  -noContinuousRestart \
  ${SELION_OPTS} &
NODE_PID=$!

trap shutdown SIGTERM SIGINT
wait $NODE_PID
