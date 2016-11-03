#!/bin/bash
docker run -it --rm \
-v "$PWD":/usr/src/mymaven \
-w /usr/src/mymaven maven:3.3.9-jdk-8-alpine \
mvn -DskipTests -Dselion.version=$1 -B -q -s settings.xml clean package
