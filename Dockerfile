FROM ubuntu:focal

# Prevents a prompt during installation asking for user's timezone, and other interactive features
ENV DEBIAN_FRONTEND=noninteractive

# Install D compiler. Instructions adapted from https://dlang.org/download.html
RUN apt-get update --fix-missing && apt install -y wget && \
    wget https://netcologne.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list && \
    apt-get update --allow-insecure-repositories && \
    apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring && \
    apt-get update && apt-get install -y dmd-compiler dub

# Install Gtk bindings for D
RUN apt-get install -y libgtkd-3-dev

# Copy source files required for building
COPY dub.json /
COPY dub.selections.json /
COPY source /source/

# Run tests
RUN dub test

# Build optimized binary
RUN dub build --build release