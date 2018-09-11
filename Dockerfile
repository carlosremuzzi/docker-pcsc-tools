FROM alpine:3.8

WORKDIR /usr/src/build

RUN apk add --no-cache \
        ccid \
        perl \
        pcsc-lite \
        pcsc-lite-dev \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        build-base \
        curl \
        gettext \
        libressl-dev \
        libtool \
        m4 \
        readline-dev \
        zlib-dev

RUN curl -fsL https://github.com/LudovicRousseau/pcsc-tools/archive/pcsc-tools-1.5.3.tar.gz -o pcsc-tools-1.5.3.tar.gz \
    && tar -zxf pcsc-tools-1.5.3.tar.gz \
    && rm pcsc-tools-1.5.3.tar.gz \
    && cd pcsc-tools-pcsc-tools-1.5.3 \
    && mkdir -p /usr/share/pcsc \
    && cp smartcard_list.txt /usr/share/pcsc \
    && ./bootstrap \
    && ./configure \
    && make \
    && make install
 
RUN apk del .build-deps

ENTRYPOINT ["pcscd","-f","-x"]
