## Komodo Insight Explorer

### Notes

Explorer uses [https://github.com/jl777/komodo](https://github.com/jl777/komodo) **dev** branch komodod (as it already included all needed for bitcore insight: `txindex`, `addressindex`, `timestampindex`,
`spentindex` and zmq support). 

Installation is fully automated, just launch `install_explorer.sh` script from this repo. It will install needed dependencies, download and compile komodod source, install correct version of NodeJS and create KMD and all assets explorer folders and launch scripts.

Also, during installation it will used following node-js modules from this repo:

- bitcore-node-komodo
- bitcore-lib-komodo
- bitcore-build-komodo
- insight-api-komodo
- bitcore-message-komodo
- insight-ui-komodo

Some ideas in installation script taken from [https://github.com/SuperNETorg/komodo-block-explorer](https://github.com/SuperNETorg/komodo-block-explorer) . Thx to @radix42 , @flamingice , @ca333, @satindergrewal and all authors and contributors for their hard work.

### Key features

- Import SSH key to GitHub account **don't** required for install node modules, it will use HTTPS instead of SSH connection to GitHub.
- Errors with `currency.js` and `address.js` are already fixed .
- Display of Notary Node names in "Mined by" section.
- Fixed display of coinbase transactions on mobile devices.
- Fixed block reward display for KMD (it's always 3 KMD).

### How to install?

Installation script was tested on clean installation of Ubuntu 16.04.4 LTS (other OS, like Debian, not tested ... may be it will required some additional dependencies or something else, pull requests and fixes are welcome).

	git clone https://github.com/DeckerSU/komodo-explorers-install explorer
	cd explorer
	./install-explorer.sh
	
If you are get some errors during last install or you break installation process manually - delete `*-explorer`, `node-modules` folders and `*-explorer-start.sh` scripts before launching `./install-explorer.sh` script again.

After `./install-explorer.sh` finished his work you will end up with following directory and files structure:

	node-modules # folder, containing common NodeJS modules
	KMD-explorer # folder for KMD explorer
	REVS-explorer # folder for REVS explorer
	...
	KMD-explorer-start.sh # launch script for KMD explorer
	REVS-explorer-start.sh # launch script for REVS explorer
	...

![ ](./directory_structure.png  "explorer directory structure")

Corresponding daemons (komodod) for assets will be already started (see last step of ./install-explorer.sh).

After install step is complete run `assets_changes.sh` to change block reward display
for assets to 0.0001 and change assetname in explorer.

### Ports Table

You can get this table on your system using `getports.sh`:

| Coin  | RPC port | ZMQ port | Web port | P2P port | Magic (hex) | Magic (dec) 
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |------------- |
| KMD | 8232 | 8332 | 3001 | 7771 |
| REVS | 8233 (8233) | 8333 | 3002 | 10195 | 0x4141771a | 1094809370 |
| SUPERNET | 8234 (8234) | 8334 | 3003 | 11340 | 0xb9112456 | -1190058922 |
| DEX | 8235 (8235) | 8335 | 3004 | 11889 | 0x0ace51e0 | 181293536 |
| PANGEA | 8236 (8236) | 8336 | 3005 | 14067 | 0x686a3517 | 1751790871 |
| JUMBLR | 8237 (8237) | 8337 | 3006 | 15105 | 0x1e45b23a | 507884090 |
| BET | 8238 (8238) | 8338 | 3007 | 14249 | 0x07f56179 | 133521785 |
| CRYPTO | 8239 (8239) | 8339 | 3008 | 8515 | 0xaaae7cb4 | -1431405388 |
| HODL | 8240 (8240) | 8340 | 3009 | 14430 | 0x00cc1675 | 13375093 |
| MSHARK | 8241 (8241) | 8341 | 3010 | 8845 | 0x9ef4e9f0 | -1628116496 |
| BOTS | 8242 (8242) | 8342 | 3011 | 11963 | 0x042956ec | 69818092 |
| MGW | 8243 (8243) | 8343 | 3012 | 12385 | 0xa796157c | -1483336324 |
| COQUI | 8244 (8244) | 8344 | 3013 | 14275 | 0xdf23f344 | -551292092 |
| WLC | 8245 (8245) | 8345 | 3014 | 12166 | 0x00592ed5 | 5844693 |
| KV | 8246 (8246) | 8346 | 3015 | 8298 | 0xc5f134f4 | -974048012 |
| CEAL | 8247 (8247) | 8347 | 3016 | 11115 | 0x905f8c09 | -1872786423 |
| MESH | 8248 (8248) | 8348 | 3017 | 9454 | 0xb6bf6b4d | -1228969139 |
| MNZ | 8249 (8249) | 8349 | 3018 | 14336 | 0xde6fd053 | -563097517 |
| AXO | 8250 (8250) | 8350 | 3019 | 12926 | 0x179d00ba | 396165306 |
| ETOMIC | 8251 (8251) | 8351 | 3020 | 10270 | 0xe8902a07 | -393205241 |
| BTCH | 8252 (8252) | 8352 | 3021 | 8799 | 0xff5e1cf4 | -10609420 |
| PIZZA | 8253 (8253) | 8353 | 3022 | 11607 | 0x3c52bead | 1012055725 |
| BEER | 8254 (8254) | 8354 | 3023 | 8922 | 0x6ebbec9f | 1857809567 |
| NINJA | 8255 (8255) | 8355 | 3024 | 8426 | 0xb26f8eb3 | -1301311821 |
| OOT | 8256 (8256) | 8356 | 3025 | 12466 | 0xad4b5ba7 | -1387570265 |
| BNTN | 8257 (8257) | 8357 | 3026 | 14357 | 0x8e321899 | -1909319527 |
| CHAIN | 8258 (8258) | 8358 | 3027 | 15586 | 0xe0a98e56 | -525758890 |
| PRLPAY | 8259 (8259) | 8359 | 3028 | 9678 | 0x61f88ac5 | 1643678405 |
| DSEC | 8260 (8260) | 8360 | 3029 | 11556 | 0xc7b2a699 | -944593255 |

### To do

Later i will add some useful scripts and nginx configuration example.

