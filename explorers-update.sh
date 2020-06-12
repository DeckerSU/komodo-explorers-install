#!/usr/bin/env bash

STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

CUR_DIR=$(pwd)
echo Current directory: $CUR_DIR
echo -e "$STEP_START[ Step 1 ]$STEP_END Update all explorers ..."

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

# for updating node modules we don't need to kill node at update stage, but anyway we need to restart all explorers after update
# this you should do manually, for example, by starting explorers-start.sh (!)

# Killing all previous instances ...
# kill -9 $(pidof bitcore)

#declare -a kmd_coins=(REVS SUPERNET DEX PANGEA JUMBLR BET CRYPTO HODL MSHARK BOTS MGW COQUI WLC KV CEAL MESH MNZ AXO ETOMIC BTCH PIZZA BEER NINJA OOT BNTN CHAIN PRLPAY DSEC GLXT EQL ZILLA RFOX)
source $CUR_DIR/kmd_coins.sh
for i in "${kmd_coins[@]}"
do
    echo -e "$STEP_START[ $i ]$STEP_END"
    if [[ ! " ${disabled_coins[@]} " =~ " ${i} " ]]; then
        cd $CUR_DIR/$i-explorer
        nvm use v4; npm update
        cd $CUR_DIR
    fi
done

# now we are ready to make assetchains specific changes
$CUR_DIR/assets-changes.sh
# don't forget to copy overlay to apply custom styles, logos, texts and other assetchain specific info




