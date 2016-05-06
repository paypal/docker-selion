#!/bin/bash
VERSION=$1

echo FROM selion/node-chrome:$VERSION > ./Dockerfile
cat ./Dockerfile.txt >> ./Dockerfile
