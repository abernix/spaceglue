FROM debian:jessie
MAINTAINER Jesse Rosenberger

ENV METEORD_DIR /opt/meteord
COPY scripts $METEORD_DIR

ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-4.6.1}
ONBUILD ENV NODE_VERSION ${NODE_VERSION:-4.6.1}

RUN $METEORD_DIR/lib/install_base.sh
RUN $METEORD_DIR/lib/install_node.sh
RUN $METEORD_DIR/lib/install_phantomjs.sh
RUN $METEORD_DIR/lib/cleanup.sh

EXPOSE 80
ENTRYPOINT $METEORD_DIR/run_app.sh
