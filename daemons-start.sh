#!/bin/bash

STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

CUR_DIR=$(pwd)
echo Current directory: $CUR_DIR
echo -e "$STEP_START[ Step 1 ]$STEP_END Daemons start"
cd $CUR_DIR/komodo/src
echo "pubkey=028eea44a09674dda00d88ffd199a09c9b75ba9782382cc8f1e97c0fd565fe5707" > pubkey.txt # remove this if you are not Decker :)
./assetchains
cd $CUR_DIR
