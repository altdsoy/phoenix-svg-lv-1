ARG ELIXIR_VERSION=1.18.1
ARG ERLANG_VERSION=27.2
ARG ALPINE_VERSION=3.21.0
FROM hexpm/elixir:$ELIXIR_VERSION-erlang-$ERLANG_VERSION-alpine-$ALPINE_VERSION

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.

# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG USERNAME=vscode

RUN addgroup -g $USER_GID $USERNAME \
  && adduser -S -s /bin/ash -u $USER_UID -G $USERNAME $USERNAME \
  # [Optional] Add sudo support for the non-root user
  && apk add --no-cache sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME

# Install git, bash, dependencies, and add a non-root user
# build-base for Argon2 compilation
RUN apk add --no-cache --update build-base gcompat inotify-tools tzdata git bash

RUN cp /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
  echo "Europe/Paris" > /etc/timezone

RUN mkdir -p /app && chown -R $USER_UID:$USER_GID /app
USER vscode

RUN mix local.rebar --force && \
  mix local.hex --force
