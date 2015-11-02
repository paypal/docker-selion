#!/bin/bash

# Assumptions:
# Selion grid files in /opt/selion
# SELION_HOME defined in env
# JAVA available on PATH

CONF=$SELION_HOME/config/hubConfig.json

$SELION_HOME/generate_config >$CONF
echo "starting selenium hub with configuration:"
cat $CONF

function shutdown {
    echo "shutting down hub.."
    kill -s SIGTERM $NODE_PID
    wait $NODE_PID
    echo "shutdown complete"
}

cd $SELION_HOME && java -DselionHome=$SELION_HOME ${JAVA_OPTS} \
  -classpath $SELION_HOME/selenium-server-standalone.jar:$SELION_HOME/SeLion-Grid.jar \
  -jar $SELION_HOME/SeLion-Grid.jar \
  -role hub \
  -hubConfig $CONF \
	-selionConfig /opt/selion/config/SeLionConfig.json \
  -noContinuousRestart &
NODE_PID=$!

trap shutdown SIGTERM SIGINT
wait $NODE_PID
