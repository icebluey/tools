#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -e
systemctl start docker
sleep 5
if [ "$(cat /proc/cpuinfo | grep -i '^processor' | wc -l)" -gt 1 ]; then
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name ub2204 -itd ubuntu:22.04 bash
else
    docker run --rm --name ub2204 -itd ubuntu:22.04 bash
fi
sleep 2
docker exec ub2204 apt update -y
docker exec ub2204 apt install -y bash wget ca-certificates curl git openssl binutils coreutils util-linux findutils diffutils patch sed gawk grep file gzip bzip2 xz-utils tar
docker exec ub2204 /bin/ln -svf bash /bin/sh
docker exec ub2204 apt upgrade -fy
docker exec ub2204 /bin/bash -c '/bin/rm -fr /tmp/*'
docker cp .preinstall_ub2204 ub2204:/home/
docker exec ub2204 /bin/bash /home/.preinstall_ub2204

docker cp hy ub2204:/home/
docker exec ub2204 /bin/bash /home/hy/build.sh
rm -fr /tmp/_output_assets
mkdir /tmp/_output_assets
docker cp ub2204:/tmp/hysteria /tmp/_output_assets/

docker cp v2 ub2204:/home/
docker exec ub2204 /bin/bash /home/v2/build.sh
docker cp ub2204:/tmp/v2ray /tmp/_output_assets/

exit
