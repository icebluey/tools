/usr/bin/warp-cli --accept-tos registration new
/usr/bin/warp-cli --accept-tos mode proxy
/usr/bin/warp-cli --accept-tos proxy port 10005
/usr/bin/warp-cli --accept-tos tunnel protocol set MASQUE
/usr/bin/warp-cli --accept-tos tunnel masque-options set h3-only
/usr/bin/warp-cli --accept-tos connect
echo
sleep 5
/usr/bin/warp-cli --accept-tos status
echo
sleep 1
/usr/bin/warp-cli --accept-tos settings

# The MASQUE protocol is now the only protocol that can use Proxy mode.
#/usr/bin/warp-cli --accept-tos tunnel protocol set MASQUE
#/usr/bin/warp-cli --accept-tos tunnel masque-options set h3-only
#/usr/bin/warp-cli --accept-tos tunnel masque-options set h3-with-h2-fallback
#/usr/bin/warp-cli --accept-tos tunnel masque-options set h2-only

#/usr/bin/warp-cli --accept-tos tunnel protocol set WireGuard

