FROM buildpack-deps:jessie-curl
MAINTAINER Jesse Rosenberger

ADD apt-sources.list /etc/apt/sources.list

ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-4.6.1}

ENV NODESOURCE_DEBIAN_DIST jessie
ENV NODESOURCE_BASEURL https://deb.nodesource.com/node_4.x
ENV NODESOURCE_BASEPATH /pool/main/n/nodejs/
ENV NODESOURCE_DEB_PATH nodejs_${NODE_VERSION}-1nodesource1~${NODESOURCE_DEBIAN_DIST}1_amd64.deb

ADD "${NODESOURCE_BASEURL}${NODESOURCE_BASEPATH}${NODESOURCE_DEB_PATH}" \
  /tmp/node.deb

RUN (dpkg -i /tmp/node.deb 2> /dev/null || true) && \
  rm /tmp/node.deb

RUN apt-get update && apt-get -f install -y && apt-get install -y \
    iptables \
  && rm -rf /var/lib/apt/lists/*

RUN ["npm", "install", "--global", "npm@3"]

# Clean up the packages, and our mess.
RUN npm cache clear && apt-get autoremove -y && rm -rf \
  /usr/share/doc \
  /usr/share/doc-base \
  /usr/share/man \
  /usr/share/locale \
  /usr/share/zoneinfo \
  /var/lib/cache \
  /var/lib/log \
  /tmp/*

# For legacy reasons only, we run on port 80
# This allows Meteor Up to keep doing --port THEIRPORT:80, which is hard-coded
# by many implementations.  The actual server will run unprivileged though,
# thanks to dockers default run cap of NET_BIND_SERVICE=true
EXPOSE 80

# Create a non-privileged user to do most all the work as.
# We do this now to create the home directory.
RUN groupadd -r node && useradd -r -g node node

# Do the rest in the 'node' user home directory.
WORKDIR /home/node
ONBUILD WORKDIR /home/node
COPY scripts .

# Set permissions before we leave.
RUN chown -R node:node /home/node/

# If we're using the old built_app directory, set the permissions for it.
RUN test -d /built_app && \
  chmod 700 /built_app && \
  chown -Rh node:node /built_app \
  || true

# Change to the node user for execution.
USER node

ENTRYPOINT ./run_app.sh
