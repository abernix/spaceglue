FROM abernix/meteord:base
MAINTAINER Jesse Rosenberger

ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-4.6.1}

COPY scripts/install_binbuild_tools.sh $METEORD_DIR/install_binbuild_tools.sh
COPY scripts/rebuild_npm_modules.sh $METEORD_DIR/rebuild_npm_modules.sh

RUN $METEORD_DIR/install_binbuild_tools.sh
