#!/bin/bash

CUR_DIR=$(pwd)
mkdir -p $CUR_DIR/helper
mkdir -p $CUR_DIR/helper/nginx/sites-available
#declare -a kmd_coins=(REVS SUPERNET DEX PANGEA JUMBLR BET CRYPTO HODL MSHARK BOTS MGW COQUI WLC KV CEAL MESH MNZ AXO ETOMIC BTCH PIZZA BEER NINJA OOT BNTN CHAIN PRLPAY DSEC GLXT EQL)
source $CUR_DIR/kmd_coins.sh

# Let's Encrypt Renewal + DNS Zone + Nginx
homedir=/home/decker
webroot=$homedir/insight
basehost=yourserver.com
iphost=1.1.1.1
proxy_pass_host=localhost

echo "# DNS Zone Configuration" > $CUR_DIR/helper/dns_zones.txt
echo -n sudo letsencrypt certonly --webroot -w $webroot > $CUR_DIR/helper/letsencrypt.txt

echo "@ 10800 IN A $iphost" >> $CUR_DIR/helper/dns_zones.txt
echo "www 10800 IN A $iphost" >> $CUR_DIR/helper/dns_zones.txt

echo -n " -d $basehost -d www.$basehost" >> $CUR_DIR/helper/letsencrypt.txt

webport=3001

for i in "${kmd_coins[@]}"
do
	# https://stackoverflow.com/questions/2264428/how-to-convert-a-string-to-lower-case-in-bash
	hostname=$(echo $i | tr '[:upper:]' '[:lower:]')
	echo -n " -d $hostname.$basehost " >> $CUR_DIR/helper/letsencrypt.txt
	echo "$hostname 10800 IN A $iphost" >> $CUR_DIR/helper/dns_zones.txt
	webport=$((webport+1))


cat <<EOF > $CUR_DIR/helper/nginx/sites-available/$hostname.$basehost 
# --- 
# https://sysadmin.pm/nginx-rate-limit/
# https://www.nginx.com/blog/rate-limiting-nginx/
# https://gist.github.com/ipmb/472da2a9071dd87e24d3

geo \$limit {
 default 1;
 127.0.0.1 0;
 23.152.0.13 0;
 94.130.148.142 0;
}

map \$limit \$limit_key {
 0 "";
 1 \$binary_remote_addr;
}

# limit_req_zone \$binary_remote_addr zone=api:10m rate=1r/s;
limit_req_zone \$limit_key zone=${hostname}_api:10m rate=1r/s;

server {
    listen 80;
    server_name $hostname.$basehost;
    location /.well-known {
        root $webroot;
    }
    location / {
    return 301 https://\$server_name\$request_uri;
    }
}

server {
  #listen 80;
  listen 443 ssl;
  server_name $hostname.$basehost;

  ssl_certificate	/etc/letsencrypt/live/$basehost/fullchain.pem;
  ssl_certificate_key   /etc/letsencrypt/live/$basehost/privkey.pem;

  root $webroot;
  access_log $homedir/logs/$hostname.$basehost-access.log;
  error_log  $homedir/logs/$hostname.$basehost-error.log;

  location / {
    proxy_pass http://$proxy_pass_host:$webport;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
    proxy_set_header X-Real-IP  \$remote_addr;
    proxy_set_header X-Forwarded-For \$remote_addr;
    # ip allow and deny rules
    # deny 23.152.0.13;
  }

  location /insight-api-komodo {
    # apply rate limiting
    limit_req zone=${hostname}_api burst=10 nodelay;

    proxy_pass http://$proxy_pass_host:$webport;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
    proxy_set_header X-Real-IP  \$remote_addr;
    proxy_set_header X-Forwarded-For \$remote_addr;
  }

   location /.well-known {
        # Note that a request for /.well-known/test.html will
        # look for $webroot/.well-known/test.html
        # and not $webroot/test.html
        root $webroot;
    }
}
# ---
EOF

done
echo >> $CUR_DIR/helper/letsencrypt.txt
