#!/bin/bash
systemctl stop warp-svc.service
rm -vf /bin/warp-svc /bin/warp-dex /bin/warp-diag /bin/warp-cli /bin/warp-taskbar
sleep 1

dnf install -y "${1}"

sleep 1
systemctl stop warp-svc.service
sleep 1
systemctl disable warp-svc.service

if [ -f /etc/systemd/system/warp-svc.service ]; then
  rm -vf /lib/systemd/system/warp-svc.service
  cp -vf /etc/systemd/system/warp-svc.service /lib/systemd/system/warp-svc.service
  rm -vf /etc/systemd/system/warp-svc.service
fi

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
chown cfwarp:cfwarp /var/log/warp-svc/warp_svc.log
chmod 0644 /var/log/warp-svc/warp_svc.log

rm -fr /var/log/cloudflare-warp
systemctl start warp-svc.service
sleep 2
systemctl enable warp-svc.service
exit
