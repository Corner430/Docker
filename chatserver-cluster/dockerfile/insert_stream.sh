#!/bin/bash

# 定义stream块的内容
STREAM_BLOCK="
stream {
        upstream MyServer {
                hash \$remote_addr consistent;
                server 127.0.0.1:6000 weight=1 max_fails=3 fail_timeout=30s;
                server 127.0.0.1:6001 weight=1 max_fails=3 fail_timeout=30s;
                # keepalive 32;
        }

        server {
                proxy_connect_timeout 1s;
                proxy_timeout 3s;
                listen 8000;
                proxy_pass MyServer;
                tcp_nodelay on;
        }
}
"

# 定义nginx配置文件的路径
NGINX_CONF="nginx.conf"

# 使用awk插入stream块
awk -v stream="$STREAM_BLOCK" '
/http {/ {
    print stream
}
{ print }
' $NGINX_CONF > temp.conf && mv temp.conf $NGINX_CONF