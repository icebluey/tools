
https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/download-warp/
https://developers.cloudflare.com/cloudflare-one/changelog/warp/

```
curl -x "socks5://127.0.0.1:10005" https://icanhazip.com
curl -x "http://127.0.0.1:10005" https://icanhazip.com

curl -x "socks5://127.0.0.1:10005" https://ipinfo.io 2>/dev/null | jq .
curl -x "http://127.0.0.1:10005" https://ipinfo.io 2>/dev/null | jq .

```
