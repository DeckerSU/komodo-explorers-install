#!/usr/bin/env bash

CUR_DIR=$(pwd)

echo '
|   | Coin  | RPC port | ZMQ port | Web port | P2P port | Magic (hex) | Magic (dec) |
| - | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |------------- |
| ✅ | KMD | 8232 | 8332 | 3001 | **7770** | 0x8de4eef9 |  2380590841|'

rpcport=8232
zmqport=8332
webport=3001

#declare -a kmd_coins=(REVS SUPERNET DEX PANGEA JUMBLR BET CRYPTO HODL MSHARK BOTS MGW COQUI WLC KV CEAL MESH MNZ AXO ETOMIC BTCH PIZZA BEER NINJA OOT BNTN CHAIN PRLPAY DSEC GLXT EQL)
source $CUR_DIR/kmd_coins.sh

for i in "${kmd_coins[@]}"
do
   rpcport=$((rpcport+1))
   zmqport=$((zmqport+1))
   webport=$((webport+1))
   daemon_getinfo=$(komodo/src/komodo-cli -ac_name=$i getinfo 2>/dev/null)
   daemon_name=$(echo $daemon_getinfo | jq .name)
   daemon_name=$(echo $daemon_name | tr -d '"')
   daemon_rpcport=$(echo $daemon_getinfo | jq .rpcport)
   daemon_p2pport=$(echo $daemon_getinfo | jq .p2pport)
   daemon_magic=$(echo $daemon_getinfo | jq .magic)
   daemon_magic_hex=$(printf '%016x' $daemon_magic)
   [ -z "${daemon_name}" ] && daemon_name=$i
   [ -z "${daemon_rpcport}" ] && daemon_rpcport=$rpcport
   # https://stackoverflow.com/questions/3685970/check-if-a-bash-array-contains-a-value
   if [[ " ${disabled_coins[@]} " =~ " ${i} " ]]; then
      daemon_flag="❎";
   else
      daemon_flag="✅";
   fi
   echo "| $daemon_flag | $i | $daemon_rpcport ($rpcport) | $zmqport | $webport | $daemon_p2pport | 0x${daemon_magic_hex: -8} | $daemon_magic |"
done
