#!/bin/bash
systemctl stop warp-svc.service
rm -vf /bin/warp-svc /bin/warp-dex /bin/warp-diag /bin/warp-cli /bin/warp-taskbar
sleep 1

dpkg -i "${1}"

sleep 1
systemctl stop warp-svc.service
systemctl disable warp-svc.service

rm -f /var/lib/cloudflare-warp/cfwarp_snapshots_collection.txt
rm -fr /var/lib/cloudflare-warp/crash_reports
rm -fr /var/lib/cloudflare-warp/snapshots
rm -fr /var/lib/cloudflare-warp/qlogs

getent group cfwarp > /dev/null || groupadd -r cfwarp
getent passwd cfwarp > /dev/null || useradd -r -d /var/lib/cloudflare-warp -g cfwarp -s /usr/sbin/nologin -c "Cloudflare Warp" cfwarp

sed -e '/^User=/d' -i /lib/systemd/system/warp-svc.service
sed -e '/^Group=/d' -i /lib/systemd/system/warp-svc.service
sed -e '/\[Service\]/aUser=cfwarp\nGroup=cfwarp' -i /lib/systemd/system/warp-svc.service
sed 's|LogsDirectory=.*|LogsDirectory=warp-svc|g' -i /lib/systemd/system/warp-svc.service
sleep 1
systemctl daemon-reload

[ -d /var/log/warp-svc ] || mkdir /var/log/warp-svc
chown cfwarp:cfwarp /var/log/warp-svc
chmod 0755 /var/log/warp-svc
touch /var/log/warp-svc/warp_svc.log
chown syslog:adm /var/log/warp-svc/warp_svc.log
chmod 0644 /var/log/warp-svc/warp_svc.log

rm -f /var/log/warp-svc/cfwarp_*
cat /dev/null > /var/log/warp-svc/warp_svc.log
rm -fr /var/log/cloudflare-warp
systemctl start warp-svc.service
sleep 2
systemctl enable warp-svc.service
exit
