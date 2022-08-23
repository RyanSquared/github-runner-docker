# Build runner from source
FROM mcr.microsoft.com/dotnet/sdk:6.0.300 AS runner-builder

ARG PACKAGE_RUNTIME=linux-x64
# Also accepts: Debug
ARG BUILD_CONFIG=Release
# Significant: trim leading v
ARG RUNNER_VERSION=2.296.0

ADD runner /opt/runner
WORKDIR /opt/runner/src

RUN dotnet msbuild -t:Build -p:PackageRuntime=$PACKAGE_RUNTIME \
    -p:BUILDCONFIG=$BUILD_CONFIG -p:RunnerVersion=$RUNNER_VERSION ./dir.proj

# Places files in /opt/runner/_layout
RUN dotnet msbuild -t:Layout -p:PackageRuntime=$PACKAGE_RUNTIME \
    -p:BUILDCONFIG=$BUILD_CONFIG -p:RunnerVersion=$RUNNER_VERSION ./dir.proj

# Build NodeJS 12 and 16
FROM debian:bullseye AS node-12-builder
ARG NODE_12_REV=v12.22.9

RUN apt-get update && apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y g++ make build-essential python2.7 git
RUN git clone https://github.com/nodejs/node && cd node && git checkout $NODE_12_REV
WORKDIR /node
RUN ./configure
RUN make -j $(nproc)
RUN mkdir /opt/out && make install PREFIX=/opt/out

FROM debian:bullseye AS node-16-builder
ARG NODE_16_REV=v16.16.0

RUN apt-get update && apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y g++ make build-essential python3 git
RUN git clone https://github.com/nodejs/node && cd node && git checkout $NODE_16_REV
WORKDIR /node
RUN ./configure
RUN make -j $(nproc)
RUN mkdir /opt/out && make install PREFIX=/opt/out

# Actual runtime
FROM debian:bullseye

# We need the following for nodesource
RUN apt-get update && apt-get upgrade -y && DEBIAN_FRONTEND=noninteractive apt-get install -y gpg apt-transport-https ca-certificates

# Create runner user, with sudo permission
RUN apt-get update && apt-get upgrade -y && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo git liblttng-ust0 libkrb5-3 zlib1g libssl1.1 libicu67 iputils-ping curl build-essential pkg-config
RUN useradd -m runner && usermod -aG sudo runner
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

COPY --from=runner-builder /opt/runner/_layout /opt/runner
RUN mkdir -p /opt/runner/externals/node12
RUN mkdir -p /opt/runner/externals/node16
RUN chown -R runner:runner /opt/runner
COPY --from=node-12-builder /opt/out /opt/runner/externals/node12
COPY --from=node-16-builder /opt/out /opt/runner/externals/node16

WORKDIR /opt/runner
USER runner
ADD entrypoint.sh /opt/runner/entrypoint.sh
ENTRYPOINT ["/opt/runner/entrypoint.sh"]
