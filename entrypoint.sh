#!/usr/bin/env bash

# 定义 UUID 及 伪装路径,请自行修改.(注意:伪装路径以 / 符号开始,为避免不必要的麻烦,请不要使用特殊符号.)
PROXY_IP='5.253.36.99'
UUID='ae14c875-f1d7-43eb-9506-eef1846d17e1'
VMESS_WSPATH='/argovmess'
VLESS_WSPATH='/argovless'
TROJAN_WSPATH='/argotrojan'
SS_WSPATH='/argoshadowsocks'
NEZHA_SERVER='nezhadata.hkpass.top'
NEZHA_PORT='443'
NEZHA_KEY='i6l9u6g39G3D6LXdqW'
sed -i "s#PROXY_IP#$PROXY_IP#g;s#UUID#$UUID#g;s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g;s#TROJAN_WSPATH#${TROJAN_WSPATH}#g;s#SS_WSPATH#${SS_WSPATH}#g" config.json
sed -i "s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g;s#TROJAN_WSPATH#${TROJAN_WSPATH}#g;s#SS_WSPATH#${SS_WSPATH}#g" /etc/nginx/nginx.conf
sed -i "s#RELEASE_RANDOMNESS#${RELEASE_RANDOMNESS}#g" /etc/supervisor/conf.d/supervisord.conf

# 设置 nginx 伪装站
rm -rf /usr/share/nginx/*
wget https://gitlab.com/Misaka-blog/xray-paas/-/raw/main/mikutap.zip -O /usr/share/nginx/mikutap.zip
unzip -o "/usr/share/nginx/mikutap.zip" -d /usr/share/nginx/html
rm -f /usr/share/nginx/mikutap.zip

# 伪装 xray 执行文件
RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
mv xray ${RELEASE_RANDOMNESS}
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
cat config.json | base64 > config
rm -f config.json

# 如果有设置哪吒探针三个变量,会安装。如果不填或者不全,则不会安装
[ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_PORT}" ] && [ -n "${NEZHA_KEY}" ] && wget https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -O nezha.sh && chmod +x nezha.sh && ./nezha.sh install_agent ${NEZHA_SERVER} ${NEZHA_PORT} ${NEZHA_KEY} --tls

nginx
base64 -d config > config.json
./${RELEASE_RANDOMNESS} -config=config.json