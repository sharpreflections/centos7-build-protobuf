###############################################################################
# Parameters
###############################################################################

ARG prefix=/opt

###############################################################################
# Base Image
###############################################################################

FROM centos:centos7 as base

ARG prefix

###############################################################################
# Builder Image
###############################################################################

FROM centos7-base as builder

RUN yum -y install \
        unzip \
        autoconf \
        automake \
        libtool \
 && echo "Downloading protobuf 3.0.2:" \
 && curl --progress-bar https://codeload.github.com/protocolbuffers/protobuf/tar.gz/v3.0.2 --output protobuf-3.0.2.tar.gz \
 && echo "Downloading protobuf 3.5.2:" \
 && curl --progress-bar https://codeload.github.com/protocolbuffers/protobuf/tar.gz/v3.5.2 --output protobuf-3.5.2.tar.gz \
 && for file in *; \
    do \
      echo -n "Extracting $file: " \
      && tar -xf $file \
      && echo "done";\
    done \
 && source scl_source enable devtoolset-8 \
 && cd protobuf-3.0.2 \
 && ./autogen.sh \
 && ./configure --prefix=/opt/protobuf-3.0 \
 && make --jobs=$(nproc --all) \
 && make install \
 && cd ../protobuf-3.5.2 \
 && ./autogen.sh \
 && ./configure --prefix=/opt/protobuf-3.5 \
 && make --jobs=$(nproc --all) \
 && make install \
 && rm -rf /build/*

###############################################################################
# Final Image
###############################################################################

FROM base

ARG prefix

COPY --from=builder ${prefix} ${prefix}