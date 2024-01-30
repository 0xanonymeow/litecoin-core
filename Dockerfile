FROM debian:stable-slim

LABEL maintainer=0xanonymeow<anonymeow@incatni.to> \
      description="litecoin core" \
      version="1.0"

ENV COIN_TMP="/var/tmp/"
ENV LITECOIN_DATA=/home/litecoin/.litecoin
ENV GOSU_VERSION=1.17

ARG LOAD_CONFIG_FROM_GIST=false
ARG CONFIG_GUESS_URL=https://gist.githubusercontent.com/0xanonymeow/99fbaeefeadc33def63bc3d93a3417fb/raw/16ac3e8454f75ee0b1a8e627f50de2fb67377fb6/config.guess
ARG CONFIG_GUESS_HASH=63b141da70e8d546917c4d140095c8da4dcc5bf4cad902f0007fed14105f1ecc
ARG CONFIG_SUB_URL=https://gist.githubusercontent.com/0xanonymeow/99fbaeefeadc33def63bc3d93a3417fb/raw/16ac3e8454f75ee0b1a8e627f50de2fb67377fb6/config.sub
ARG CONFIG_SUB_HASH=93716c32dc11fbbf4dee83b2cc4b73330d21d0a373c3362419efdd054ca8e595

RUN useradd -r litecoin && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    git \
    wget \
    build-essential \
    libtool \
    autotools-dev \
    automake \
    pkg-config \
    libssl-dev \
    libevent-dev \
    bsdmainutils \
    python3 \
    libboost-all-dev \
    libfmt-dev \
    libdb++-dev

RUN set -eux; \
    apt-get install -y gosu; \
	rm -rf /var/lib/apt/lists/*; \
    # verify that the binary works
	gosu nobody true

RUN git clone https://github.com/litecoin-project/litecoin.git ${COIN_TMP} && \
    if [ "$LOAD_CONFIG_FROM_GIST" != false ]; then \
        INSTALL_DB4_PATH=${COIN_TMP}contrib/install_db4.sh && \
        sed -i "s|^CONFIG_GUESS_URL=.*$|CONFIG_GUESS_URL=${CONFIG_GUESS_URL}|g" ${INSTALL_DB4_PATH} && \
        sed -i "s|^CONFIG_GUESS_HASH=.*$|CONFIG_GUESS_HASH=${CONFIG_GUESS_HASH}|g" ${INSTALL_DB4_PATH} && \
        sed -i "s|^CONFIG_SUB_URL=.*$|CONFIG_SUB_URL=${CONFIG_SUB_URL}|g" ${INSTALL_DB4_PATH} && \
        sed -i "s|^CONFIG_SUB_HASH=.*$|CONFIG_SUB_HASH=${CONFIG_SUB_HASH}|g" ${INSTALL_DB4_PATH}; \
    fi && \
    cd ${COIN_TMP} && \
    ./contrib/install_db4.sh `pwd` && \
    ./autogen.sh && \
    BDB_PREFIX='${COIN_TMP}/db4' && \
    ./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" && \
    make -j "$(($(nproc)+1))" NO_QT=1 NO_QR=1 NO_ZMQ=1 NO_SQLITE=1 NO_UPNP=1 && \
    make install && \
    rm -rf /var/lib/apt/lists/* /tmp/* ${COIN_TMP}*

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/home/litecoin/.litecoin"]

EXPOSE 9332 9333 19332 19333 19444

ENTRYPOINT ["/entrypoint.sh"]

CMD ["litecoind"]
