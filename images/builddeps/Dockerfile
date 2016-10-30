FROM abernix/spaceglue:base
MAINTAINER Jesse Rosenberger

USER root
RUN apt-get update && apt-get -f install -y && apt-get install -y --no-install-recommends \
    build-essential \
    fontconfig \
    libfreetype6-dev \
    libssl-dev \
    g++ \
    python \
  && rm -rf /var/lib/apt/lists/*

RUN ["npm", "install", "--global", "node-gyp"]

USER node
