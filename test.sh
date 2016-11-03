#!/usr/bin/env bash
VERSION=${VERSION-develop}
SELION_VERSION=${SELION_VERSION}

function build_test_container {
  echo Building test container image
  docker build -t selion/smoketest:$VERSION ./test
}

function startup {
  echo 'Starting Selion Hub Container ...'
  HUB=$(docker run -d selion/hub:$VERSION)
  HUB_NAME=$(docker inspect -f '{{ .Name  }}' $HUB | sed s:/::)
  echo 'Waiting for Hub to come online ...'
  docker logs -f $HUB &
  sleep 2

  echo 'Starting Selion Chrome node ...'
  NODE_CHROME=$(docker run -d --link $HUB_NAME:hub -v /dev/shm:/dev/shm selion/node-chrome:$VERSION)
  echo 'Starting Selion Firefox node ...'
  NODE_FIREFOX=$(docker run -d --link $HUB_NAME:hub selion/node-firefox:$VERSION)
  echo 'Starting Selion Phantomjs node ...'
  NODE_PHANTOMJS=$(docker run -d --link $HUB_NAME:hub selion/node-phantomjs:$VERSION)
  docker logs -f $NODE_CHROME &
  docker logs -f $NODE_FIREFOX &
  docker logs -f $NODE_PHANTOMJS &
  echo 'Waiting for nodes to register and come online ...'
  sleep 3
}

function teardown {
  echo Removing the test container
  docker rm $TEST_CONTAINER

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
}

function test_nodes {
  BROWSER=$1

  echo Running Node tests ...
  docker run -it --link $HUB_NAME:hub \
  -e TEST_SUITE=GridSuite.xml \
  -e SELION_VERSION=$SELION_VERSION \
  selion/smoketest:$VERSION

  STATUS=$?
  TEST_CONTAINER=$(docker ps -aq | head -1)

  if [ ! $STATUS == 0 ]; then
    echo Failed
    teardown
    exit 1
  fi
}

#-------------
# main
#-------------

build_test_container
startup
test_nodes
teardown
