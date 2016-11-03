#!/usr/bin/env bash
VERSION=${VERSION-develop}
SELION_VERSION=${SELION_VERSION}

function build_test_container {
  echo Building test container image
  docker build -t selion/smoketest:$VERSION ./test
}

function teardown {
  echo Tearing down Selion standalone-$BROWSER container
  docker stop $SA_NAME
  docker rm $SA_NAME
  echo Removing the test container
  docker rm $TEST_CONTAINER
}

function test_standalone {
  BROWSER=$1
  echo Starting Selion standalone-$BROWSER container

  SA=$(docker run -d selion/standalone-$BROWSER:$VERSION)
  sleep 2
  SA_NAME=$(docker inspect -f '{{ .Name  }}' $SA | sed s:/::)

  echo Running test container...
  docker run -it -v /dev/shm:/dev/shm --link $SA_NAME:hub \
  -e BROWSER=$BROWSER \
  -e TEST_SUITE=StandaloneSuite.xml \
  -e SELION_VERSION=$SELION_VERSION \
  selion/smoketest:$VERSION

  STATUS=$?
  TEST_CONTAINER=$(docker ps -aq | head -1)

  if [ ! $STATUS == 0 ]; then
    echo Failed
    teardown
    exit 1
  fi
  teardown
}

#-------------
# main
#-------------
build_test_container

test_standalone firefox
test_standalone chrome
test_standalone phantomjs
