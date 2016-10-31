# docker-selion

## Docker images for SeLion (grid) server Hub and Node configurations with Chrome and Firefox.

[![Build Status](https://travis-ci.org/paypal/docker-selion.svg?branch=develop)](https://travis-ci.org/paypal/docker-selion)
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/paypal/SeLion?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Find us on [Gitter](https://gitter.im/paypal/SeLion)

These images build on the Selenium docker images here https://github.com/SeleniumHQ/docker-selenium

Images included here:
- __selion/base__: Base image which includes Java runtime, Selenium + SeLion JAR files
- __selion/hub__: Image for running a Selion Grid Hub
- __selion/node-base__: Base image for the SeLion node images
- __selion/node-chrome__: SeLion node with Chrome installed, needs to be connected to a SeLion Grid Hub
- __selion/node-firefox__: SeLion node with Firefox installed, needs to be connected to a SeLion Grid Hub
- __selion/node-phantomjs__: SeLion node with Phantomjs installed, needs to be connected to a SeLion Grid Hub
- __selion/standalone-chrome__: SeLion standalone with Chrome installed
- __selion/standalone-firefox__: SeLion standalone with Firefox installed
- __selion/standalone-phantomjs__: SeLion standalone with Phantomjs installed

## Running the images

When executing docker run for an image with chrome browser please add volume mount `-v /dev/shm:/dev/shm` to use the host's shared memory.

``` bash
$ docker run -d -p 4444:4444 -v /dev/shm:/dev/shm selion/node_chrome:1.0.0
```

This is a workaround to node-chrome crash in docker container issue: https://code.google.com/p/chromium/issues/detail?id=519952

### Selion Grid Hub

``` bash
$ docker run -d -p 4444:4444 --name selion-hub selion/hub:1.0.0
```

### SELION_OPTS options

You can pass `SELION_OPTS` variable with additional commandline parameters for starting a hub or a node. So to run a SeLion sauce hub.

### Selion Grid Sauce Hub

``` bash
$ docker run -d -p 4444:4444 -e SELION_OPTS="-type sauce" --name selion-hub selion/hub:1.0.0
```

### Chrome and Firefox Grid Nodes

``` bash
$ docker run -d --link selion-hub:hub selion/node-chrome:1.0.0
$ docker run -d --link selion-hub:hub selion/node-firefox:1.0.0
```

### Java Environment Options

You can pass JAVA_OPTS environment variable to selenium java processes.

``` bash
$ docker run -d -p 4444:4444 -e JAVA_OPTS=-Xmx512m --name selion-hub selion/hub:1.0.0
```

## Building the images

Ensure you have the `ubuntu:15.04` base image downloaded, this step is _optional_ since Docker takes care of downloading the parent base image automatically.

``` bash
$ docker pull ubuntu:15.04
```

Clone the repo and from the project directory root you can build everything by running:

``` bash
$ VERSION=local make build
```

_Note: Omitting_ `VERSION=local` _will build the images with the develop version number thus overwriting the images downloaded from [Docker Hub](https://registry.hub.docker.com/)._

## Using the images

##### Example: Spawn a container for testing in Chrome:

``` bash
$ docker run -d --name selion-hub -p 4444:4444 selion/hub:1.0.0
$ CH=$(docker run --rm --name=ch \
    --link selion-hub:hub -v /e2e/uploads:/e2e/uploads \
    selion/node-chrome:1.0.0-SNAPSHOT)
```

_Note:_ `-v /e2e/uploads:/e2e/uploads` _is optional in case you are testing browser uploads on your web app you will probably need to share a directory for this._

##### Example: Spawn a container for testing in Firefox:

This command line is the same as for Chrome. Remember that the Selenium running container is able to launch either Chrome or Firefox, the idea around having 2 separate containers, one for each browser is for convenience plus avoiding certain `:focus` issues your web app may encounter during end-to-end test automation.

``` bash
$ docker run -d --name selion-hub -p 4444:4444 selion/hub:1.0.0
$ FF=$(docker run --rm --name=fx \
    --link selion-hub:hub -v /e2e/uploads:/e2e/uploads \
    selion/node-firefox:1.0.0)
```

_Note: Since a Docker container is not meant to preserve state and spawning a new one takes less than 3 seconds you will likely want to remove containers after each end-to-end test with_ `--rm` _command. You need to think of your Docker containers as single processes, not as running virtual machines, in case you are familiar with [Vagrant](https://www.vagrantup.com/)._


### Troubleshooting

All output is sent to stdout so it can be inspected by running:
``` bash
$ docker logs -f <container-id|container-name>
```

License
-------
[The Apache Software License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)
