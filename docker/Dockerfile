FROM ubuntu:20.04 AS komodod-builder
# Dockerfile for the explorer (q) Decker, 2022-2024
# https://github.com/DeckerSU/komodo-explorers-install/

# Build: docker build -f Dockerfile -t kmdexplorer .
# Run interactive: docker run -v ${PWD}/.zcash-params:/home/explorer/.zcash-params -v ${PWD}/.komodo:/home/explorer/.komodo -e DAEMON_ARGS="-ac_public=1 -ac_name=KIP0001 -ac_supply=139419284 -ac_staked=10 -addnode=178.159.2.6" -e WEB_PORT=3002 -p 127.0.0.1:3002:3002 -it kmdexplorer
# Run background:  docker run -v ${PWD}/.zcash-params:/home/explorer/.zcash-params -v ${PWD}/.komodo:/home/explorer/.komodo -e DAEMON_ARGS="-ac_public=1 -ac_name=KIP0001 -ac_supply=139419284 -ac_staked=10 -addnode=178.159.2.6" -p 127.0.0.1:3001:3001 -dt kmdexplorer
# Exit interactive without stopping It: press Ctrl+P followed by Ctrl+Q
# Attach to container console: docker attach followed by the name or ID of the container.

# Installing dependencies
RUN \
    apt-get update && apt-get install -y --no-install-recommends build-essential pkg-config libc6-dev m4 g++-multilib &&\
    apt-get install -y --no-install-recommends autoconf libtool ncurses-dev unzip git python3 python3-zmq zlib1g-dev wget &&\
    apt-get install -y --no-install-recommends libcurl4-gnutls-dev bsdmainutils automake curl libsodium-dev libcurl4-gnutls-dev &&\
    apt-get install -y --no-install-recommends apt-transport-https ca-certificates libzmq3-dev sudo jq python2

# Building komodod
RUN \
    git clone -b static-experimental https://github.com/DeckerSU/KomodoOcean &&\
    cd KomodoOcean &&\
    ./zcutil/build-no-qt.sh -j$(nproc --all) &&\
    cd ..

FROM ubuntu:20.04
RUN \
    apt-get update && apt-get install -y --no-install-recommends sudo wget ca-certificates jq libzmq3-dev git python2 &&\
    apt-get install -y --no-install-recommends build-essential &&\
    apt-get -y clean && apt-get -y autoclean &&\
    rm -rf /var/{lib/apt/lists/*,cache/apt/archives/*.deb,tmp/*,log/*} /tmp/*

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r explorer && useradd -r -g explorer -m explorer &&\
    adduser explorer sudo &&\
    echo "explorer ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/explorer 

RUN mkdir -p /home/explorer/bin
COPY --from=komodod-builder /KomodoOcean/src/komodod /KomodoOcean/src/komodo-cli /KomodoOcean/zcutil/fetch-params.sh /home/explorer/bin/
RUN chown -R explorer:explorer /home/explorer/bin

USER explorer
WORKDIR /home/explorer

ENV PATH="/home/explorer/bin:${PATH}"
ENV NVM_DIR="/home/explorer/.nvm"
# RUN \
#     echo 'alias k="/home/explorer/bin/komodo-cli "' > ~/.bash_aliases

# Install nvm
RUN  \
    wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.35.0/install.sh | bash &&\
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" &&\
    nvm install v4

# fix the access rights and setup an entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN \
    sudo chmod +x /usr/local/bin/docker-entrypoint.sh &&\
    sudo ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh &&\
    sudo rm -rf /home/explorer/.komodo && sudo mkdir -p /home/explorer/.komodo &&\
    sudo rm -rf /home/explorer/.zcash-params && sudo mkdir -p /home/explorer/.zcash-params &&\
    sudo chown -R explorer:explorer /home/explorer/.komodo /home/explorer/.zcash-params

# volumes, should be overriden with -v or -mount when container is up
VOLUME /home/explorer/.komodo
VOLUME /home/explorer/.zcash-params

ENTRYPOINT ["docker-entrypoint.sh"]
# CMD ["start"]








