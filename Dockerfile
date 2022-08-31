###############################################################################
# Parameters
###############################################################################

ARG prefix=/opt

###############################################################################
# Base Image
###############################################################################

FROM quay.io/centos/centos:centos7 as base

ARG prefix

###############################################################################
# Builder Image
###############################################################################

FROM quay.io/sharpreflections/centos7-build-base as builder

ARG prefix

RUN yum -y install \
        unzip \
        autoconf \
        automake \
        libtool \
        devtoolset-8 \
 \
 && echo "Downloading protobuf 3.0.2:" \
 && curl --progress-bar https://codeload.github.com/protocolbuffers/protobuf/tar.gz/v3.0.2 --output protobuf-3.0.2.tar.gz \
 && echo -n "Extracting protobuf 3.0.2: " \
 && tar -xf protobuf-3.0.2.tar.gz \
 && echo "done" \
 \
 && echo "Downloading protobuf 3.5.2:" \
 && curl --progress-bar https://codeload.github.com/protocolbuffers/protobuf/tar.gz/v3.5.2 --output protobuf-3.5.2.tar.gz \
 && echo -n "Extracting protobuf 3.5.2: " \
 && tar -xf protobuf-3.5.2.tar.gz \
 && echo "done" \
 \
 && source scl_source enable devtoolset-8 \
 \
 && cd protobuf-3.0.2 \
 && ./autogen.sh \
 && ./configure --prefix=${prefix}/protobuf-3.0 \
 && make --jobs=$(nproc --all) \
 && make install \
 \
 && cd ../protobuf-3.5.2 \
 && ./autogen.sh \
 && ./configure --prefix=${prefix}/protobuf-3.5 \
 && make --jobs=$(nproc --all) \
 && make install \
 \
 && rm -rf /build/*

###############################################################################
# Final Image
###############################################################################

FROM base

ARG prefix

COPY --from=builder ${prefix} ${prefix}
