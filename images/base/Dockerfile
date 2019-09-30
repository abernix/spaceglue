FROM buildpack-deps:jessie-curl
MAINTAINER Jesse Rosenberger

ADD apt-sources.list /etc/apt/sources.list

# To set the NODE_VERSION, use a --build-arg to `docker build`.
# (But really, use build_it.sh and set NODE_VERSION in your environment first)
ARG NODE_VERSION

# Do not continue unless NODE_VERSION is set.
RUN if [ -z ${NODE_VERSION} ]; then \
  echo "ERROR: Must set NODE_VERSION as a build argument!" && \
  exit 1; \
  fi

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN apt-get update && apt-get install -y \
  && apt-get install -y nodejs=${NODE_VERSION}-1nodesource1 \
  && rm -rf /var/lib/apt/lists/*

# The version just installed would have been not the latest, and very likely
# could have been pre-6.x.  Let's update to 6.x.
RUN ["npm", "install", "--global", "npm@6"]

# Clean up the packages, and our mess.
RUN npm cache clear --force && apt-get autoremove -y && rm -rf \
  /usr/share/doc \
  /usr/share/doc-base \
  /usr/share/man \
  /usr/share/locale \
  /usr/share/zoneinfo \
  /var/lib/cache \
  /var/lib/log \
  /tmp/*

# Create a non-privileged user to do most all the work as.
# We do this now to create the home directory.
RUN groupadd -r node && useradd -r -m -g node node

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

# Run on port 3000 and expose this so node knows this when we launch.
ENV PORT 3000
EXPOSE ${PORT}

# Change to the node user for execution.
USER node

ENTRYPOINT ./run_app.sh
