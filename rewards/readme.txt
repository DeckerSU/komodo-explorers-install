This directory contain patches for rewards display:

0001-add-Reward-info-to-Insight-Explorer-by-gaeacodes.patch -> bitcore-node-komodo
0002-add-Reward-info-to-Insight-Explorer-by-gaeacodes.patch -> insight-api-komodo
0003-add-Reward-info-to-Insight-Explorer-by-gaeacodes.patch -> insight-ui-komodo

Example of apply patch:

cp 0001-add-Reward-info-to-Insight-Explorer-by-gaeacodes.patch ~/komodo-explorers-install/KMD-explorer/node_modules/bitcore-node-komodo
cd ~/komodo-explorers-install/KMD-explorer/node_modules/bitcore-node-komodo
---------
git apply -v 0001-add-Reward-info-to-Insight-Explorer-by-gaeacodes.patch
---------
...

komodo-explorers-install (1)
└─── KMD-explorer
     └─── node_modules
          ├── bitcore-lib-komodo
          ├── bitcore-node-komodo
          ├── insight-api-komodo (2)
          └── insight-ui-komodo (3)

If top-level (1) of your directory structure with explorers have '.git' folder, rename it to '.git-bak' or delete
it, otherwise git apply will not apply patches (it will skip them instead, as top-folder have .git folder inside).
Under (2) you should execute `npm install moment` command, bcz moment module is needed for this implementation.

main.min.js and other files under insight-ui-komodo should be placed into corresponding folder in (3), otherwise
Time Rewards Accrued and KMD Available to Claim fields will display incorrectly.
