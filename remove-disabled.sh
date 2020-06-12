#!/usr/bin/env bash
STEP_START='\e[1;47;42m'
STEP_END='\e[0m'

CUR_DIR=$(pwd)
echo Current directory: $CUR_DIR
echo -e "$STEP_START[ Step 1 ]$STEP_END Remove disable explorers data ..."
source $CUR_DIR/kmd_coins.sh
for i in "${disabled_coins[@]}"
do
    echo -e "$STEP_START[ $i ]$STEP_END"
    echo -n "Do you wish to remove $i data [yN]? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm $i-explorer-start.sh
        rm "${i}_7776"
        rm -rf $i-explorer
        rm -rf $HOME/.komodo/$i/blocks
        rm -rf $HOME/.komodo/$i/chainstate
        rm -rf $HOME/.komodo/$i/notarisations
        rm $HOME/.komodo/$i/db.log
        rm $HOME/.komodo/$i/debug.log
        rm $HOME/.komodo/$i/fee_estimates.dat
        rm $HOME/.komodo/$i/komodostate
        rm $HOME/.komodo/$i/komodostate.ind
        rm $HOME/.komodo/$i/peers.dat
        rm $HOME/.komodo/$i/signedmasks
    fi
done

