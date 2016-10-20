FROM debian:jessie
MAINTAINER Jesse Rosenberger

WORKDIR /opt/meteord
ONBUILD WORKDIR /opt/meteord
COPY scripts .

ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-4.6.1}
ENV JESSE1=true

ENV NODESOURCE_DEBIAN_DIST jessie
ENV NODESOURCE_BASEURL https://deb.nodesource.com/node_4.x
ENV NODESOURCE_BASEPATH /pool/main/n/nodejs/
ENV NODESOURCE_DEB_PATH nodejs_${NODE_VERSION}-1nodesource1~${NODESOURCE_DEBIAN_DIST}1_amd64.deb

ADD "${NODESOURCE_BASEURL}${NODESOURCE_BASEPATH}${NODESOURCE_DEB_PATH}" node.deb

RUN (dpkg -i node.deb 2> /dev/null || true) && rm node.deb

RUN apt-get update && apt-get -f install -y && apt-get install -y \
    bzip2 \
    build-essential \
    curl \
    fontconfig \
    libfreetype6-dev \
    libssl-dev \
    g++ \
    git \
    python \
  && rm -rf /var/lib/apt/lists/*

RUN ["npm", "install", "--global", "npm@3"]
RUN ["npm", "install", "--global", "node-gyp"]
RUN ["npm", "install", "--global", "phantomjs@1"]

RUN lib/cleanup.sh

ONBUILD ENV BUILDJESSE1=true
ONBUILD COPY ./ /app
ONBUILD RUN lib/install_meteor.sh
ONBUILD RUN lib/build_app.sh

EXPOSE 80
ENTRYPOINT ./run_app.sh
