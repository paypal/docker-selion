#!/bin/bash
VERSION=$1

echo FROM selion/base:$VERSION > ./Dockerfile
cat ./Dockerfile.txt >> ./Dockerfile
