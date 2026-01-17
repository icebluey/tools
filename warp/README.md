
https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/download-warp/
https://developers.cloudflare.com/cloudflare-one/changelog/warp/

```
curl -x "socks5://127.0.0.1:10005" https://icanhazip.com
curl -x "http://127.0.0.1:10005" https://icanhazip.com

curl -x "socks5://127.0.0.1:10005" https://ipinfo.io 2>/dev/null | jq .
curl -x "http://127.0.0.1:10005" https://ipinfo.io 2>/dev/null | jq .

```

```
curl https://1.1.1.1/cdn-cgi/trace
curl -x "socks5://127.0.0.1:10005" https://1.1.1.1/cdn-cgi/trace
curl -x "socks5://127.0.0.1:1080" https://1.1.1.1/cdn-cgi/trace
```


```
Notice: The Cloudflare WARP APT repository public key may require updating. Please run:
  curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output "/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg"
```
