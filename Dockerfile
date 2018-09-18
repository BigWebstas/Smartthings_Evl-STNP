FROM base/archlinux

ARG architecture=x64
ARG node_version=6.11.1
ARG build_date
ARG repo=redloro
ARG branch=master

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="rpi-smartthings-nodeproxy" \
      org.label-schema.description="SmartThings Node Proxy for Raspberry Pi" \
      org.label-schema.version="1.0.2" \
      org.label-schema.docker.cmd="docker run -d -p 8080:8080 -e ENABLED_PLUGINS='' --device=/dev/ttyUSB0 rpi-smartthings-nodeproxy" \
      org.label-schema.build-date=$build_date \
      architecture=$architecture

RUN pacman -Syu \
 && packman -S wget \
 && wget -O - https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-${architecture}.tar.xz \
  | tar -xJvf - --strip-components=1 -C /usr/local/ \
 && rm -rf /tmp/* 

ENV NODE=/usr/local/bin/node
ENV NPM=/usr/local/bin/npm
ENV PYTHON=/usr/bin/python2.7

RUN pacman -S python2 libpcap wget \
 && mkdir -p /stnp/plugins \
 && wget -O - https://github.com/${repo}/smartthings/tarball/${branch} \
  | tar -xzvf - --wildcards --strip-components=2 -C /stnp/ ${repo}-smartthings-*/smartthings-nodeproxy/ \
 && cd /stnp \
 && rm -f restart.me smartthings-nodeproxy.service config.json \
 && npm install \
 && npm install serialport@4.0.7 \
 && npm install https://github.com/node-pcap/node_pcap/tarball/master \
 && rm -rf /tmp/* 

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY config.sample /stnp/config.json

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]

