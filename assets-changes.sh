#!/bin/bash

CUR_DIR=$(pwd)
#declare -a kmd_coins=(REVS SUPERNET DEX PANGEA JUMBLR BET CRYPTO HODL MSHARK BOTS MGW COQUI WLC KV CEAL MESH MNZ AXO ETOMIC BTCH PIZZA BEER NINJA OOT BNTN CHAIN PRLPAY DSEC GLXT EQL)
source $CUR_DIR/kmd_coins.sh

for i in "${kmd_coins[@]}"
do
sed -i 's/3 \* 1e8/1 \* 1e4/g' $CUR_DIR/$i-explorer/node_modules/insight-api-komodo/lib/blocks.js
sed -i "s/\"TAZ\":\"KMD\"/\"TAZ\":\"$i\"/g" $CUR_DIR/$i-explorer/node_modules/insight-ui-komodo/public/js/main.min.js
#sed -i "s/\"TAZ\":\"\$i\"/\"TAZ\":\"$i\"/g" $CUR_DIR/$i-explorer/node_modules/insight-ui-komodo/public/js/main.min.js
done
