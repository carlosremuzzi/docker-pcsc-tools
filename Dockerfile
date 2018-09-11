FROM alpine:3.8

WORKDIR /usr/src/build

RUN apk add --no-cache --virtual .build-deps \
    autoconf \
    build-base \
    curl \
    gettext \
    libressl-dev \
    libtool \
    m4 \
    pcsc-lite \
    pcsc-lite-dev \
    readline-dev \
    zlib-dev

RUN curl -fsL https://github.com/OpenSC/OpenSC/releases/download/0.18.0/opensc-0.18.0.tar.gz  -o opensc-0.18.0.tar.gz \
    && tar -zxf opensc-0.18.0.tar.gz \
    && rm opensc-0.18.0.tar.gz \
    && cd opensc-0.18.0 \
    && ./bootstrap \
    && ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --disable-man \
        --enable-thread_locking \
        --enable-zlib \
        --enable-readline \
        --enable-openssl \
        --enable-pcsc \
        --enable-sm \
    && make

RUN apk del .build-deps
