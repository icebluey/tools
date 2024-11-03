#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
cd "$(dirname "$0")"
bash build-hysteria-linux.sh
bash build-hysteria-win.sh
exit

