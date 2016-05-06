#!/bin/bash

SELENIUM_VERSION=$1
SELENIUM_FIX=$2
REPO=$3
SELION_GRID_VERSION=$4

cat ./Dockerfile.txt > ./Dockerfile

# The Selenium server version (Keep in sync with SeLion server)
sed -i.bkp -e "s/%SELENIUM_VERSION%/$SELENIUM_VERSION/g" ./Dockerfile
sed -i.bkp -e "s/%SELENIUM_FIX%/$SELENIUM_FIX/g" ./Dockerfile
# Where to pull the SeLion-Grid artifact from REPO = 'snapshots' || REPO = 'releases'
sed -i.bkp -e "s/%REPO%/$REPO/g" ./Dockerfile
# SeLion-Grid artifact version
sed -i.bkp -e "s/%SELION_GRID_VERSION%/$SELION_GRID_VERSION/g" ./Dockerfile

rm -f ./Dockerfile.bkp
