### How to start the explorer with Docker?

Docker feature for launch explorers in in early alpha version. Take this into account before usage.

- To start the explorer with Docker you need to build the container with `docker build -f Dockerfile -t kmdexplorer` from the directory containing `docker-entrypoint.sh` and `Dockerfile` files. 
- Then you should launch the container with:

```
docker run -v ${PWD}/.zcash-params:/home/explorer/.zcash-params -v ${PWD}/.komodo:/home/explorer/.komodo -e DAEMON_ARGS="-ac_public=1 -ac_name=KIP0001 -ac_supply=139419284 -ac_staked=10" -e WEB_PORT=3002 -p 127.0.0.1:3002:3002 -it kmdexplorer
```

- This will create `.zcash-params` folder and `.komodo` folder in current (!) directory, container will automatically fill it with needed info. All you need is to specify the daemon arguments in `DAEMON_ARGS` environment variable. Currently only assetchains (!) are supported, KMD is untested. Specifying `DAEMON_ARGS` is mandatory.
- After the container starts up and the daemon performs the necessary block checks, bitcore will start:

    ![Running container](./container-001.png)

- Bitcore will output everything in stdout and, as the container was launched with `-it`, you are now in an interactive bash shell. To keep the container running in the foreground, press Ctrl-P followed by Ctrl-Q.



