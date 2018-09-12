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
        perl-dev \
        readline-dev \
        zlib-dev

COPY add-ecc-curves.patch libressl-2.7.patch  ./

RUN curl -fsL https://github.com/OpenSC/OpenSC/releases/download/0.18.0/opensc-0.18.0.tar.gz  -o opensc-0.18.0.tar.gz \
    && tar -zxf opensc-0.18.0.tar.gz \
    && rm opensc-0.18.0.tar.gz \
    && mv *.patch opensc-0.18.0 \
    && cd opensc-0.18.0 \
    && patch src/tools/pkcs11-tool.c -i add-ecc-curves.patch \
    && patch src/libopensc/sc-ossl-compat.h -i libressl-2.7.patch \
    && ./bootstrap \
    && ./configure \
        --host=x86_64-alpine-linux-musl \
        --prefix=/usr \
        --sysconfdir=/etc \
        --disable-man \
        --enable-zlib \
        --enable-readline \
        --enable-openssl \
        --enable-pcsc \
        --enable-sm \
        CC='gcc' \
        LDFLAGS='-Wl,--as-needed' \
        CFLAGS='-fno-strict-aliasing -Os -fomit-frame-pointer -Werror=declaration-after-statement' \
    && make \
    && make install

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

RUN curl -fsL http://ludovic.rousseau.free.fr/softwares/pcsc-perl/pcsc-perl-1.4.14.tar.bz2 -o pcsc-perl-1.4.14.tar.bz2 \
    && tar -jxf pcsc-perl-1.4.14.tar.bz2 \
    && rm pcsc-perl-1.4.14.tar.bz2 \
    && cd pcsc-perl-1.4.14 \
    && PERL_MM_USE_DEFAULT=1 perl Makefile.PL INSTALLDIRS=vendor \
    && make DESTDIR="$pkgdir" install

RUN apk del .build-deps \
    && rm -rf /usr/src/build

WORKDIR /home/nobody

RUN mkdir -p /run/pcscd \
    && chown -R nobody:nobody /run/pcscd

USER nobody
