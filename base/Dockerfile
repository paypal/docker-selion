FROM ubuntu:15.04
MAINTAINER Selion <selion@googlegroups.com>

# Builds on docker selenium (https://github.com/SeleniumHQ/docker-selenium) which we customize for SeLion.
# This is copy of selenium base.  Inheriting FROM selenium base didn't allow over-riding some
# choices already made in selenium base.

# This Docker is just a base for the other SeLion docker images.

# TODOs:
# Selenium using openjdk (openjdk-8-jre-headless)
# Consider this base instead https://github.com/phusion/baseimage-docker

#==============================
# Customize sources for apt-get
#==============================
RUN  echo "deb http://archive.ubuntu.com/ubuntu vivid main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu vivid-updates main universe\n" >> /etc/apt/sources.list

#==============================
# Miscellaneous packages
# Includes minimal runtime used for executing non GUI Java programs
#==============================
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    ca-certificates \
    openjdk-8-jre-headless \
    sudo \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/* \
  && sed -i 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' ./usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

# The Selenium server version (Keep in sync with Selion server)
ENV SELENIUM_VERSION 2.45
ENV SELENIUM_FIX 0

# The SeLion version (used to pull from github)
ENV SELION_VERSION 1.0.0-SNAPSHOT-M4

# Selenium base was already using /opt
ENV SELION_HOME /opt/selion

# Download Webserver
ENV SEL_SERVER https://selenium-release.storage.googleapis.com
ENV REDIRECT_URL https://oss.sonatype.org/nexus/service/local/artifact/maven/redirect

#=============================
# Add selion + selenium server
#=============================
# TODO pull latest snapshot jar from sonatype
RUN mkdir -p ${SELION_HOME} \
  && wget --no-verbose https://github.com/paypal/SeLion/releases/download/v${SELION_VERSION}/SeLion-Grid-${SELION_VERSION}.jar -O /opt/selion/SeLion-Grid.jar \
  && wget --no-verbose $SEL_SERVER/${SELENIUM_VERSION}/selenium-server-standalone-${SELENIUM_VERSION}.${SELENIUM_FIX}.jar -O /opt/selion/selenium-server-standalone.jar

#RUN  mkdir -p $SELION_HOME \
#  && wget --no-verbose "$REDIRECT_URL?r=sonatype-nexus-snapshots&g=com.paypal.selion&a=SeLion-Grid&c=jar-with-dependencies&v=LATEST" -O $SELION_HOME/SeLion-Grid.jar \
#  && wget --no-verbose $SEL_SERVER/$SELENIUM_VERSION/selenium-server-standalone-$SELENIUM_VERSION.$SELENIUM_FIX.jar -O /opt/selion/selenium-server-standalone.jar

#========================================
# Add normal user with passwordless sudo
#========================================
RUN sudo useradd seluser --shell /bin/bash --create-home \
  && sudo usermod -a -G sudo seluser \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'seluser:secret' | chpasswd
