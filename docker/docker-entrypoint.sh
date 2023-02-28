#!/bin/bash
set -eo pipefail
shopt -s nullglob

# logging functions
explorer_log() {
	local type="$1"; shift
	# accept argument string or stdin
	local text="$*"; if [ "$#" -eq 0 ]; then text="$(cat)"; fi
	local dt; dt="$(date --rfc-3339=seconds)"
	printf '%s [%s] [Entrypoint]: %s\n' "$dt" "$type" "$text"
}
explorer_note() {
	explorer_log Note "$@"
}
explorer_warn() {
	explorer_log Warn "$@" >&2
}
explorer_error() {
	explorer_log ERROR "$@" >&2
	exit 1
}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		explorer_error "Both $var and $fileVar are set (but are exclusive)"
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}

# Verify that the minimally settings are set
docker_verify_minimum_env() {
    # https://stackoverflow.com/questions/54077210/meaning-of-a-z-in-if-z-env-var-a-z-env-var2-bash-conditional
	if [ -z "$DAEMON_ARGS" -a -z "$COIN_NAME" -a -z "$COIN_RPC_PORT" -a -z "$COIN_RPC_USER" -a -z "$COIN_RPC_PASS" -a -z "$COIN_ZMQ_PORT" -a -z "$COIN_WEB_PORT" ]; then
		explorer_error <<-'EOF'
			Needed options are not specified, probable incorrect DAEMON_ARGS
			    The following variables should be specified:
			    - DAEMON_ARGS
			    - COIN_NAME
			    - COIN_RPC_PORT
                - COIN_RPC_USER
                - COIN_RPC_PASS
                - COIN_ZMQ_PORT
                - COIN_WEB_PORT
		EOF
	fi
}

create_bitcore_config() {
    cat << EOF > $1/bitcore-node.json
{
  "network": "mainnet",
  "port": ${COIN_WEB_PORT},
  "services": [
    "bitcoind",
    "insight-api-komodo",
    "insight-ui-komodo",
    "web"
  ],
  "servicesConfig": {
    "bitcoind": {
      "connect": [
        {
          "rpchost": "127.0.0.1",
          "rpcport": ${COIN_RPC_PORT},
          "rpcuser": "${COIN_RPC_USER}",
          "rpcpassword": "${COIN_RPC_PASS}",
          "zmqpubrawtx": "tcp://127.0.0.1:${COIN_ZMQ_PORT}"
        }
      ]
    },
  "insight-api-komodo": {
    "rateLimiterOptions": {
      "whitelist": ["::ffff:127.0.0.1","127.0.0.1"],
      "whitelistLimit": 500000, 
      "whitelistInterval": 3600000 
    }
  }
  }
}
EOF
}

rewrite_daemon_config() {
    cat <<EOF > $HOME/.komodo/${COIN_NAME}/${COIN_NAME}.conf
server=1
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
zmqpubrawtx=tcp://127.0.0.1:${COIN_ZMQ_PORT}
zmqpubhashblock=tcp://127.0.0.1:${COIN_ZMQ_PORT}
rpcallowip=127.0.0.1
rpcport=${COIN_RPC_PORT}
rpcuser=${COIN_RPC_USER}
rpcpassword=${COIN_RPC_PASS}
uacomment=bitcore
showmetrics=0
bitcoreready=1
EOF
}

write_explorer_start_script() {
    cat << EOF > ${NODE_DIR}/${COIN_NAME}-explorer-start.sh
#!/bin/bash
    pushd ${NODE_DIR}/${COIN_NAME}-explorer
    while true; do
    ./node_modules/bitcore-node-komodo/bin/bitcore-node start
    sleep 5
    done
    popd
EOF
chmod +x ${NODE_DIR}/${COIN_NAME}-explorer-start.sh
}

_main() {

# if [ "$1" = 'start' ]; then
    sudo chown -R explorer:explorer /home/explorer/.komodo /home/explorer/.zcash-params
    explorer_note "Fetching ZCash params"
    ${HOME}/KomodoOcean/zcutil/fetch-params.sh 1>/dev/null 2>/dev/null
    explorer_note "ZCash params download finished."
    declare -g COIN_NAME COIN_RPC_PORT COIN_P2P_PORT COIN_RPC_USER COIN_RPC_PASS COIN_ZMQ_PORT COIN_WEB_PORT COIN_DESC
    if [ ! -z "$DAEMON_ARGS" ]
    then
        # there is a bug with testnet, when indexes changed in config during reindex, so use regtest (!)
        explorer_note "Starting temporary server"
        komodod $DAEMON_ARGS --regtest --listen=0 --connect=127.0.0.1 --maxconnections=0 --daemon --reindex=0
        explorer_note "Temporary server started."
        sleep 5
        komodo-cli $DAEMON_ARGS --regtest getinfo > /tmp/getinfo.json 2>/dev/null
        explorer_note "Stopping temporary server"
        komodo-cli $DAEMON_ARGS --regtest stop 1>/dev/null 2>/dev/null
        explorer_note "Temporary server stopped"

        COIN_NAME=$(cat /tmp/getinfo.json | jq -r .name)
        COIN_RPC_PORT=$(cat /tmp/getinfo.json | jq -r .rpcport)
        COIN_P2P_PORT=$(cat /tmp/getinfo.json | jq -r .p2pport)
        COIN_RPC_USER=$(grep -s '^rpcuser=' "${HOME}/.komodo/${COIN_NAME}/${COIN_NAME}.conf")
        COIN_RPC_PASS=$(grep -s '^rpcpassword=' "${HOME}/.komodo/${COIN_NAME}/${COIN_NAME}.conf")
        COIN_RPC_USER=${COIN_RPC_USER/rpcuser=/}
        COIN_RPC_PASS=${COIN_RPC_PASS/rpcpassword=/}
        COIN_ZMQ_PORT=$((COIN_RPC_PORT + 1))
        # https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
        COIN_WEB_PORT=${WEB_PORT:-3001}
    fi

    # https://stackoverflow.com/questions/1305237/how-to-list-variables-declared-in-script-in-bash
    for var in ${!COIN@}; do
    explorer_note $(printf "%s%q\n" "$var=" "${!var}")
    done

    docker_verify_minimum_env
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm use v4
    mkdir -p $HOME/.komodo/node
    pushd $HOME/.komodo/node
    NODE_DIR=$(pwd)
    [ ! -d node_modules ] && npm install git+https://git@github.com/DeckerSU/bitcore-node-komodo || explorer_note "Bitcore node already installed."

    if [ ! -d ${COIN_NAME}-explorer ]; then
        explorer_note "Let's create Bitcore stuff"
        ${NODE_DIR}/node_modules/bitcore-node-komodo/bin/bitcore-node create ${COIN_NAME}-explorer
        pushd ${COIN_NAME}-explorer
        ${NODE_DIR}/node_modules/bitcore-node-komodo/bin/bitcore-node install git+https://git@github.com/DeckerSU/insight-api-komodo git+https://git@github.com/DeckerSU/insight-ui-komodo
        popd
        popd
        create_bitcore_config "${NODE_DIR}/${COIN_NAME}-explorer"
    else
        explorer_note "Bitcore stuff already exists."
    fi

    # rewrite daemon config
    rewrite_daemon_config
    # start daemon
    komodod $DAEMON_ARGS --daemon
    # write explorer start script
    write_explorer_start_script
    # start bitcore process in background
    explorer_note "Starting bitcore in foreground"
    ${NODE_DIR}/${COIN_NAME}-explorer-start.sh &
    explorer_note "Seems everything done, let's wait for catch up"
    /bin/bash

# fi
# exec "$@"
}

# If we are sourced from elsewhere, don't perform any further actions
if ! _is_sourced; then
	_main "$@"
fi
