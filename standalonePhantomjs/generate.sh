#!/bin/bash
VERSION=$1

echo FROM selion/node-phantomjs:$VERSION > ./Dockerfile
cat ./Dockerfile.txt >> ./Dockerfile
