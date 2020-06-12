#!/usr/bin/env bash

# this will check existing KMD coins list via active dpow coins,
# to show which explorers not running yet

CUR_DIR=$(pwd)
source $CUR_DIR/kmd_coins.sh
readarray -t dpow_coins < <(curl -s https://raw.githubusercontent.com/KomodoPlatform/dPoW/master/iguana/assetchains.json | jq -r '[.[].ac_name] | join("\n")')
num=0
for i in "${dpow_coins[@]}"
do
    if [[ ! " ${kmd_coins[@]} " =~ " ${i} " ]]; then
        num=$((num+1))
        printf "%2d. %8s" $num $i
        if [[ " ${disabled_coins[@]} " =~ " ${i} " ]]; then
            echo " (disabled)"
        else
            echo " (not running)"
        fi
    fi
done