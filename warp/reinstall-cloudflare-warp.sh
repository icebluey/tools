#!/bin/bash
systemctl stop warp-svc.service
rm -vf /bin/warp-svc /bin/warp-dex /bin/warp-diag /bin/warp-cli /bin/warp-taskbar
sleep 1

dpkg -i "${1}"

systemctl stop warp-svc.service

sed -e '/^User=/d' -i /lib/systemd/system/warp-svc.service
sed -e '/^Group=/d' -i /lib/systemd/system/warp-svc.service
sed -e '/\[Service\]/aUser=cfwarp\nGroup=cfwarp' -i /lib/systemd/system/warp-svc.service
sed 's|LogsDirectory=.*|LogsDirectory=warp-svc|g' -i /lib/systemd/system/warp-svc.service
sleep 1
systemctl daemon-reload

[ -d /var/log/warp-svc ] || mkdir /var/log/warp-svc
chown cfwarp:cfwarp /var/log/warp-svc
chmod 0777 /var/log/warp-svc
touch /var/log/warp-svc/warp_svc.log
chown syslog:adm /var/log/warp-svc/warp_svc.log

rm -fr /var/log/cloudflare-warp
systemctl start warp-svc.service
sleep 2
systemctl enable warp-svc.service
exit
