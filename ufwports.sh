#!/usr/bin/env bash

CUR_DIR=$(pwd)

rpcport=8232
zmqport=8332
webport=3001

#declare -a kmd_coins=(REVS SUPERNET DEX PANGEA JUMBLR BET CRYPTO HODL MSHARK BOTS MGW COQUI WLC KV CEAL MESH MNZ AXO ETOMIC BTCH PIZZA BEER NINJA OOT BNTN CHAIN PRLPAY DSEC GLXT EQL)
source $CUR_DIR/kmd_coins.sh

echo "sudo ufw allow 7770/tcp comment 'KMD p2p port'"

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
   if [[ ! " ${disabled_coins[@]} " =~ " ${i} " ]]; then
      echo "sudo ufw allow $daemon_p2pport/tcp comment '$daemon_name p2p port'"
   fi
done

echo "# sudo ufw allow from any to any port 3001:$webport proto tcp comment 'allow insight web ports'"