#!/bin/bash
VERSION=$1

echo FROM selion/node-base:$VERSION > ./Dockerfile
cat ./Dockerfile.txt >> ./Dockerfile
