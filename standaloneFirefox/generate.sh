#!/bin/bash
VERSION=$1

echo FROM selion/node-firefox:$VERSION > ./Dockerfile
cat ./Dockerfile.txt >> ./Dockerfile
