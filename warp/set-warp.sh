/usr/bin/warp-cli --accept-tos registration new
/usr/bin/warp-cli --accept-tos proxy port 10005
/usr/bin/warp-cli --accept-tos mode proxy
/usr/bin/warp-cli --accept-tos connect
sleep 2
/usr/bin/warp-cli --accept-tos status
/usr/bin/warp-cli --accept-tos settings

#/usr/bin/warp-cli --accept-tos tunnel protocol set MASQUE
#/usr/bin/warp-cli --accept-tos tunnel masque-options set h3-only
#/usr/bin/warp-cli --accept-tos tunnel masque-options set h3-with-h2-fallback
#/usr/bin/warp-cli --accept-tos tunnel masque-options set h2-only

#/usr/bin/warp-cli --accept-tos tunnel protocol set WireGuard
