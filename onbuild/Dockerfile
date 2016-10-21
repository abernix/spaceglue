FROM abernix/meteord:base
MAINTAINER Jesse Rosenberger

COPY scripts .

ONBUILD COPY ./ /app
ONBUILD RUN lib/build_app.sh

EXPOSE 80
ENTRYPOINT ./run_app.sh
