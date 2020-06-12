#!/usr/bin/env bash

# as the ports assigning (rpcport, zmqport, webport) is just using incremental order,
# mean REVS will have ports (8233, 8333, 3002), SUPERNET will have (8234, 8334, 3003),
# etc. - you shouldn't remove dead coins from this list, to don't broke current setup,
# especially if you have nginx configs assigned to that ports.
declare -a kmd_coins=(REVS SUPERNET DEX PANGEA JUMBLR BET CRYPTO HODL MSHARK BOTS MGW COQUICASH WLC KV CEAL MESH MNZ AXO ETOMIC BTCH PIZZA BEER NINJA OOT BNTN CHAIN PRLPAY DSEC GLXT EQL VRSC ZILLA RFOX SEC CCL PIRATE MGNX PGT)
# instead of removal dead coin from kmd_coins better to add them into disabled_coins
# array
declare -a disabled_coins=(WLC CEAL MNZ PIZZA BEER BNTN CHAIN PRLPAY DSEC GLXT EQL VRSC MGNX)