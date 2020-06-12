#!/usr/bin/env bash

#
# (c) Decker, 2018-2020
#

# Additional info:
#
# If previous installation of all explorers failure in some reasons, plz remove *-explorer folders, *-explorer-start.sh files,
# and node_modules folder before you run ./install-explorer.sh again (!). It will prevent from uncomplete installation errors.
#

# https://askubuntu.com/questions/558280/changing-colour-of-text-and-background-of-terminal
STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

CUR_DIR=$(pwd)
echo Current directory: $CUR_DIR
echo -e "$STEP_START[ Step 1 ]$STEP_END Installing dependencies"
sudo apt --yes install git
# sudo apt --yes install build-essential pkg-config libc6-dev libevent-dev m4 g++-multilib autoconf libtool libncurses5-dev unzip git python zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler libqt4-dev libqrencode-dev libdb++-dev ntp ntpdate
sudo apt --yes install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python python-zmq zlib1g-dev wget libcurl4-gnutls-dev bsdmainutils automake curl libsodium-dev
sudo apt --yes install libcurl4-gnutls-dev
sudo apt --yes install curl wget

echo -e "$STEP_START[ Step 2 ]$STEP_END Building komodod"

#if false; then
if [ -f "$CUR_DIR/komodo/src/komodod" ]; then
    echo "Komodo daemon binary already there, don't need to build ..."
else
    git clone -b dev https://github.com/KomodoPlatform/komodo
    cd $CUR_DIR/komodo
    zcutil/build.sh -j$(nproc)
    cd $CUR_DIR

    if [ -f "$HOME/.zcash-params/sprout-proving.key" ] && [ -f "$HOME/.zcash-params/sprout-verifying.key" ];
    then
        echo Sprout files already here ...
    else
        cd $CUR_DIR/komodo
        zcutil/fetch-params.sh
        cd $CUR_DIR
    fi
fi

echo -e "$STEP_START[ Step 3 ]$STEP_END Installing NodeJS and Bitcore Node"
#git clone https://github.com/DeckerSU/bitcore-node-komodo
#git clone https://github.com/DeckerSU/insight-api-komodo 
#git clone https://github.com/DeckerSU/insight-ui-komodo

#git clone https://github.com/DeckerSU/bitcore-lib-komodo
#git clone https://github.com/DeckerSU/bitcore-message-komodo
#git clone https://github.com/DeckerSU/bitcore-build-komodo

# install nodejs, n and other stuff
sudo apt --yes install libsodium-dev
sudo apt --yes install libzmq3-dev
# sudo npm install n -g
# sudo n stable

# install nvm # https://github.com/nvm-sh/nvm#install--update-script
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.35.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

# switch node setup with nvm
nvm install v4
# https://stackoverflow.com/questions/17509669/how-to-install-an-npm-package-from-github-directly

npm install git+https://git@github.com/DeckerSU/bitcore-node-komodo # npm install bitcore

echo -e "$STEP_START[ Step 4 ]$STEP_END Creating komodod configs and deploy explorers"

# Start ports
rpcport=8232
zmqport=8332
webport=3001

# KMD config
echo -e "$STEP_START[ Step 4.KMD ]$STEP_END Preparing KMD"
mkdir -p $HOME/.komodo
cat <<EOF > $HOME/.komodo/komodo.conf
server=1
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
zmqpubrawtx=tcp://127.0.0.1:$zmqport
zmqpubhashblock=tcp://127.0.0.1:$zmqport
rpcallowip=127.0.0.1
rpcport=$rpcport
rpcuser=bitcoin
rpcpassword=local321
uacomment=bitcore
showmetrics=0
#connect=172.17.112.30

addnode=5.9.102.210
addnode=78.47.196.146
addnode=178.63.69.164
addnode=88.198.65.74
addnode=5.9.122.241
addnode=144.76.94.38
addnode=89.248.166.91
EOF

# Create KMD explorer and bitcore-node.json config for it

$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node create KMD-explorer
cd KMD-explorer
$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node install git+https://git@github.com/DeckerSU/insight-api-komodo git+https://git@github.com/DeckerSU/insight-ui-komodo
cd $CUR_DIR

cat << EOF > $CUR_DIR/KMD-explorer/bitcore-node.json
{
  "network": "mainnet",
  "port": $webport,
  "services": [
    "bitcoind",
    "insight-api-komodo",
    "insight-ui-komodo",
    "web"
  ],
  "servicesConfig": {
    "bitcoind": {
      "connect": [
        {
          "rpchost": "127.0.0.1",
          "rpcport": $rpcport,
          "rpcuser": "bitcoin",
          "rpcpassword": "local321",
          "zmqpubrawtx": "tcp://127.0.0.1:$zmqport"
        }
      ]
    },
  "insight-api-komodo": {
    "rateLimiterOptions": {
      "whitelist": ["::ffff:127.0.0.1","127.0.0.1"],
      "whitelistLimit": 500000, 
      "whitelistInterval": 3600000 
    }
  }
  }
}

EOF

# creating launch script for explorer
cat << EOF > $CUR_DIR/KMD-explorer-start.sh
#!/bin/bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
cd KMD-explorer
nvm use v4; ./node_modules/bitcore-node-komodo/bin/bitcore-node start
EOF
chmod +x KMD-explorer-start.sh

# now we need to create assets configs for komodod and create explorers for each asset
#declare -a kmd_coins=(REVS SUPERNET DEX PANGEA JUMBLR BET CRYPTO HODL MSHARK BOTS MGW COQUI WLC KV CEAL MESH MNZ AXO ETOMIC BTCH PIZZA BEER NINJA OOT BNTN CHAIN PRLPAY DSEC GLXT EQL)
source $CUR_DIR/kmd_coins.sh
#declare -a kmd_coins=(REVS)

for i in "${kmd_coins[@]}"
do
   echo -e "$STEP_START[ Step 4.$i ]$STEP_END Preparing $i"
   rpcport=$((rpcport+1))
   zmqport=$((zmqport+1))
   webport=$((webport+1))
   #printf "%10s: rpc.$rpcport zmq.$zmqport web.$webport\n" $i

  if [[ ! " ${disabled_coins[@]} " =~ " ${i} " ]]; then # install only if coin not disabled

   mkdir -p $HOME/.komodo/$i
   touch $HOME/.komodo/$i/$i.conf
cat <<EOF > $HOME/.komodo/$i/$i.conf
server=1
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
zmqpubrawtx=tcp://127.0.0.1:$zmqport
zmqpubhashblock=tcp://127.0.0.1:$zmqport
rpcallowip=127.0.0.1
rpcport=$rpcport
rpcuser=bitcoin
rpcpassword=local321
uacomment=bitcore
showmetrics=0
#connect=172.17.112.30

addnode=5.9.102.210
addnode=78.47.196.146
addnode=178.63.69.164
addnode=88.198.65.74
addnode=5.9.122.241
addnode=144.76.94.38
addnode=89.248.166.91
EOF

$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node create $i-explorer
cd $i-explorer
$CUR_DIR/node_modules/bitcore-node-komodo/bin/bitcore-node install git+https://git@github.com/DeckerSU/insight-api-komodo git+https://git@github.com/DeckerSU/insight-ui-komodo
cd $CUR_DIR

cat << EOF > $CUR_DIR/$i-explorer/bitcore-node.json
{
  "network": "mainnet",
  "port": $webport,
  "services": [
    "bitcoind",
    "insight-api-komodo",
    "insight-ui-komodo",
    "web"
  ],
  "servicesConfig": {
    "bitcoind": {
      "connect": [
        {
          "rpchost": "127.0.0.1",
          "rpcport": $rpcport,
          "rpcuser": "bitcoin",
          "rpcpassword": "local321",
          "zmqpubrawtx": "tcp://127.0.0.1:$zmqport"
        }
      ]
    },
  "insight-api-komodo": {
    "rateLimiterOptions": {
      "whitelist": ["::ffff:127.0.0.1","127.0.0.1"],
      "whitelistLimit": 500000, 
      "whitelistInterval": 3600000 
    }
  }
  }
}

EOF

# creating launch script for explorer
cat << EOF > $CUR_DIR/$i-explorer-start.sh
#!/bin/bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
cd $i-explorer
nvm use v4; ./node_modules/bitcore-node-komodo/bin/bitcore-node start
EOF
chmod +x $i-explorer-start.sh
fi # install only if coin not disabled

done

echo -e "$STEP_START[ Step 5 ]$STEP_END Launching daemons"
# cd $CUR_DIR/komodo/src
# echo "pubkey=028eea44a09674dda00d88ffd199a09c9b75ba9782382cc8f1e97c0fd565fe5707" > pubkey.txt # remove this if you are not Decker :)
# ./assetchains
cd $CUR_DIR
