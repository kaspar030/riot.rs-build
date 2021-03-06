#
# RIOT-rs CI Dockerfile
#
FROM ubuntu:focal

MAINTAINER Kaspar Schleiser <kaspar@schleiser.de>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update \
    && apt-get -y install \
    build-essential curl git python3 pkg-config libssl-dev llvm-dev cmake libclang-dev gcc-arm-none-eabi clang libnewlib-nano-arm-none-eabi unzip lld gpg qemu-system-arm \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --batch --verify /tini.asc /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup target add thumbv7m-none-eabi && \
    rustup target add thumbv7em-none-eabi && \
    rustup target add thumbv7em-none-eabihf

RUN rustup install nightly-2019-12-05 && \
    rustup component add --toolchain nightly-2019-12-05 rustfmt rustc-dev && \
    cargo +nightly-2019-12-05 install --debug --git https://github.com/kaspar030/c2rust --branch for-riot c2rust

CMD ["/bin/bash"]
