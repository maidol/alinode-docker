FROM alpine:3.6

ENV ALINODE_VERSION alinode-v3.8.4

COPY alinode-v3.8.4.zip /

RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache \
      libstdc++ \
    && apk add --no-cache --virtual .build-deps \
      binutils-gold \
      curl \
      g++ \
      gcc \
      gnupg \
      libgcc \
      linux-headers \
      make \
      python \
      bash \
      unzip \
    && unzip /$ALINODE_VERSION.zip \
    && cd iojs-alinode* \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && apk del .build-deps \
    && cd .. \
    && rm -rf iojs-alinode* \
    && rm /$ALINODE_VERSION.zip

ENV YARN_VERSION 1.3.2

RUN apk add --no-cache --virtual .build-deps-yarn curl gnupg tar \
    && for key in 6A010C5166006599AA17F08146C2130DFD2497F5 ; do gpg --keyserver pgp.mit.edu --recv-keys "$key" || gpg --keyserver keyserver.pgp.com --recv-keys "$key" || gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; done \
    # && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
    # && curl -fSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
    && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
    && mkdir -p /opt/yarn && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/yarn --strip-components=1 \
    && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
    && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
    && apk del .build-deps-yarn

ENV ENABLE_NODE_LOG YES
ENV NODE_LOG_DIR /tmp
ENV HOME /root

RUN npm install -g @alicloud/agenthub --registry=https://registry.npm.taobao.org

COPY default.config.js /root
COPY start-agenthub.sh /

ENTRYPOINT [ "/start-agenthub.sh" ]