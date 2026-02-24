FROM alpine:latest as build
RUN apk add --no-cache alpine-sdk linux-headers git zlib-dev openssl-dev gperf php cmake ccache
ADD . /srv
WORKDIR /srv
RUN --mount=type=cache,target=/root/.cache/git \
    git submodule update --init --recursive
RUN mkdir -p build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=../tdlib -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER_LAUNCHER=ccache ..
RUN --mount=type=cache,target=/root/.ccache \
    cd /srv/build && \
    export CCACHE_DIR=/root/.ccache && \
    cmake --build . --target install -j$(nproc)

FROM alpine:latest
VOLUME /data

RUN apk add --no-cache zlib-dev openssl-dev libstdc++

COPY --from=build /srv/build/telegram-bot-api /usr/bin/telegram-bot-api

ENTRYPOINT ["telegram-bot-api", "--dir=/data"]
