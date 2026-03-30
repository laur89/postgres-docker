# example Dockerfile including postrgres extensions @ https://github.com/postgis/docker-postgis/blob/master/18-3.6/Dockerfile
# see also https://github.com/oss-apps/split-pro/blob/main/docker/postgres/Dockerfile
#
# note https://dev.to/shrsv/supercharge-your-postgres-docker-setup-with-extensions-3leh
# implies an init script is also needed, but doubt it
##############################################
ARG POSTGRES_MAJOR=18

FROM docker.io/postgres:${POSTGRES_MAJOR}-trixie

ARG POSTGRES_MAJOR

# Install build dependencies and pg_cron extension
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        postgresql-${POSTGRES_MAJOR}-cron \
    && rm -rf /var/lib/apt/lists/*

