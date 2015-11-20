FROM selion/node-base:1.0.0
MAINTAINER Selion <selion@googlegroups.com>

USER root

#=========
# Firefox
#=========
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    firefox \
  && rm -rf /var/lib/apt/lists/*

#========================
# Selenium Configuration
#========================
COPY config.json /opt/selion/config.json

# Empty file to suppress downloads
COPY download.json $SELION_HOME/config/download.json

RUN chown -R seluser /opt/selion

USER seluser
