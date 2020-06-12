#!/usr/bin/env bash

STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

CUR_DIR=$(pwd)
echo Current directory: $CUR_DIR
echo -e "$STEP_START[ Step 1 ]$STEP_END Starts all explorers in screen ..."

# Killing all previous instances ...
kill -9 $(pidof bitcore)

#declare -a kmd_coins=(REVS SUPERNET DEX PANGEA JUMBLR BET CRYPTO HODL MSHARK BOTS MGW COQUI WLC KV CEAL MESH MNZ AXO ETOMIC BTCH PIZZA BEER NINJA OOT BNTN CHAIN PRLPAY DSEC GLXT EQL ZILLA RFOX)
source $CUR_DIR/kmd_coins.sh
for i in "${kmd_coins[@]}"
do
    if [[ ! " ${disabled_coins[@]} " =~ " ${i} " ]]; then
        screen -d -m -S $i-explorer $CUR_DIR/$i-explorer-start.sh
    fi
done

# start KMD explorer
screen -d -m -S KMD-explorer $CUR_DIR/KMD-explorer-start.sh
