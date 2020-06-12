#!/usr/bin/env bash

STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

CUR_DIR=$(pwd)
echo Current directory: $CUR_DIR
echo -e "$STEP_START[ Step 1 ]$STEP_END Daemons start"
cd $CUR_DIR/komodo/src
echo "pubkey=0302258ff903f14c7bb118c476461759c50ce3c1d2a24d5ab1e0c8ea5d16e8395d" > pubkey.txt # remove this if you are not Decker :)
./assetchains
cd $CUR_DIR
