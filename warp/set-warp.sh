/usr/bin/warp-cli --accept-tos registration new
/usr/bin/warp-cli --accept-tos proxy port 10005
/usr/bin/warp-cli --accept-tos mode proxy
/usr/bin/warp-cli --accept-tos connect
sleep 2
/usr/bin/warp-cli --accept-tos status
/usr/bin/warp-cli --accept-tos settings

