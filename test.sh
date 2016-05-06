#!/usr/bin/env bash
DEBUG=''
VERSION=${VERSION-develop}

if [ -n "$1" ] && [ $1 == 'debug' ]; then
  DEBUG='-debug'
fi

echo Building test container image
docker build -t selion/test:local ./test

echo 'Starting Selion Hub Container...'
HUB=$(docker run -d selion/hub:$VERSION)
HUB_NAME=$(docker inspect -f '{{ .Name  }}' $HUB | sed s:/::)
echo 'Waiting for Hub to come online...'
docker logs -f $HUB &
sleep 2

echo 'Starting Selion Chrome node...'
NODE_CHROME=$(docker run -d --link $HUB_NAME:hub  selion/node-chrome$DEBUG:$VERSION)
echo 'Starting Selion Firefox node...'
NODE_FIREFOX=$(docker run -d --link $HUB_NAME:hub selion/node-firefox$DEBUG:$VERSION)
echo 'Starting Selion Phantomjs node...'
NODE_PHANTOMJS=$(docker run -d --link $HUB_NAME:hub selion/node-phantomjs$DEBUG:$VERSION)
docker logs -f $NODE_CHROME &
docker logs -f $NODE_FIREFOX &
docker logs -f $NODE_PHANTOMJS &
echo 'Waiting for nodes to register and come online...'
sleep 3

function test_node {
  BROWSER=$1
  echo Running $BROWSER test...
  TEST_CMD="node smoke-$BROWSER.js"
  docker run -it --link $HUB_NAME:hub -e TEST_CMD="$TEST_CMD" selion/test:local
  STATUS=$?
  TEST_CONTAINER=$(docker ps -aq | head -1)

  if [ ! $STATUS == 0 ]; then
    echo Failed
    exit 1
  fi

  if [ ! "$CIRCLECI" ==  "true" ]; then
    echo Removing the test container
    docker rm $TEST_CONTAINER
  fi

}

test_node chrome
test_node firefox
test_node phantomjs

if [ ! "$CIRCLECI" ==  "true" ]; then
  echo Tearing down Selion Chrome Node container
  docker stop $NODE_CHROME
  docker rm $NODE_CHROME

  echo Tearing down Selion Firefox Node container
  docker stop $NODE_FIREFOX
  docker rm $NODE_FIREFOX

  echo Tearing down Selion Phantomjs Node container
  docker stop $NODE_PHANTOMJS
  docker rm $NODE_PHANTOMJS

  echo Tearing down Selion Hub container
  docker stop $HUB
  docker rm $HUB
fi

echo Done
