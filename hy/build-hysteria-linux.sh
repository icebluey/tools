#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
/sbin/ldconfig
_install_go () {
    set -e
    _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    # Latest version of go
    #_go_version="$(wget -qO- 'https://golang.org/dl/' | grep -i 'linux-amd64\.tar\.' | sed 's/"/\n/g' | grep -i 'linux-amd64\.tar\.' | cut -d/ -f3 | grep -i '\.gz$' | sed 's/go//g; s/.linux-amd64.tar.gz//g' | grep -ivE 'alpha|beta|rc' | sort -V | uniq | tail -n 1)"

    # go1.21.X
    #_go_version="$(wget -qO- 'https://golang.org/dl/' | grep -i 'linux-amd64\.tar\.' | sed 's/"/\n/g' | grep -i 'linux-amd64\.tar\.' | cut -d/ -f3 | grep -i '\.gz$' | sed 's/go//g; s/.linux-amd64.tar.gz//g' | grep -ivE 'alpha|beta|rc' | sort -V | uniq | grep '^1\.21\.' | tail -n 1)"

    # go1.22.X
    #_go_version="$(wget -qO- 'https://golang.org/dl/' | grep -i 'linux-amd64\.tar\.' | sed 's/"/\n/g' | grep -i 'linux-amd64\.tar\.' | cut -d/ -f3 | grep -i '\.gz$' | sed 's/go//g; s/.linux-amd64.tar.gz//g' | grep -ivE 'alpha|beta|rc' | sort -V | uniq | grep '^1\.22\.' | tail -n 1)"

    # go1.23.X
    _go_version="$(wget -qO- 'https://golang.org/dl/' | grep -i 'linux-amd64\.tar\.' | sed 's/"/\n/g' | grep -i 'linux-amd64\.tar\.' | cut -d/ -f3 | grep -i '\.gz$' | sed 's/go//g; s/.linux-amd64.tar.gz//g' | grep -ivE 'alpha|beta|rc' | sort -V | uniq | grep '^1\.23\.' | tail -n 1)"

    wget -q -c -t 0 -T 9 "https://dl.google.com/go/go${_go_version}.linux-amd64.tar.gz"
    rm -fr /usr/local/go
    sleep 1
    install -m 0755 -d /usr/local/go
    tar -xof "go${_go_version}.linux-amd64.tar.gz" --strip-components=1 -C /usr/local/go/
    sleep 1
    cd /tmp
    rm -fr "${_tmp_dir}"
}
set -e
_install_go
# Go programming language
export GOROOT='/usr/local/go'
export GOPATH="$GOROOT/home"
export GOTMPDIR='/tmp'
export GOBIN="$GOROOT/bin"
export PATH="$GOROOT/bin:$PATH"
alias go="$GOROOT/bin/go"
alias gofmt="$GOROOT/bin/gofmt"
rm -fr ~/.cache/go-build
echo
go version
echo
_tmp_dir="$(mktemp -d)"
cd "${_tmp_dir}"
git clone 'https://github.com/apernet/hysteria.git'
sleep 1
cp -afr hysteria "hysteria-$(date -u +%Y%m%d)-src"
tar -zcf "hysteria-$(date -u +%Y%m%d)-src".tar.gz "hysteria-$(date -u +%Y%m%d)-src"
sleep 1
mv -f "hysteria-$(date -u +%Y%m%d)-src".tar.gz /tmp/
rm -fr "hysteria-$(date -u +%Y%m%d)-src"

cd hysteria
export HY_APP_PLATFORMS="linux/amd64-avx"
python3 hyperbole.py build -r
rm -fr /tmp/hysteria
install -m 0755 -d /tmp/hysteria/etc/hysteria
install -m 0755 -d /tmp/hysteria/usr/bin
install -v -c -m 0755 build/hysteria-linux-amd64-avx /tmp/hysteria/usr/bin/hysteria
cd /tmp/hysteria
_hysteria_version="$(./usr/bin/hysteria version 2>&1 | grep -i '^version' | awk '{print $2}' | sed 's|^[Vv]||g')"
###############################################################################
echo '[Unit]
Description=Hysteria 2 Service
After=network.target
Wants=network.target

[Service]
# Hysteria is a powerful, lightning fast and censorship resistant proxy.
# https://github.com/apernet/hysteria
# User=hysteria
# Group=hysteria
Type=simple
PIDFile=/run/hysteria.pid
AmbientCapabilities=CAP_NET_BIND_SERVICE
ExecStart=/usr/bin/hysteria server --disable-update-check --config /etc/hysteria/config.yaml
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target' > etc/hysteria/hysteria.service
sleep 1
chmod 0644 etc/hysteria/hysteria.service
###############################################################################
cat << EOF > etc/hysteria/hysteria.logrotate
/var/log/hysteria.log {
    create 0644 syslog adm
    daily
    rotate 1
    missingok
    notifempty
    compress
    sharedscripts
    postrotate
        /usr/bin/killall -HUP rsyslogd 2> /dev/null || true
        /usr/bin/killall -HUP syslogd 2> /dev/null || true
    endscript
}
EOF
###############################################################################
cat << EOF > etc/hysteria/hysteria.rsyslog
:programname, startswith, "hysteria" {
    /var/log/hysteria.log
    stop
}
EOF
###############################################################################
echo '
cd "$(dirname "$0")"
/bin/rm -f /lib/systemd/system/hysteria.service
[ -f /etc/logrotate.d/hysteria ] || install -m 0644 hysteria.logrotate /etc/logrotate.d/hysteria
[ -f /etc/rsyslog.d/10-hysteria.conf ] || install -m 0644 hysteria.rsyslog /etc/rsyslog.d/10-hysteria.conf
/usr/bin/install -v -c -m 0644 hysteria.service /lib/systemd/system/hysteria.service
/bin/systemctl daemon-reload >/dev/null 2>&1 || true
/usr/bin/killall -HUP rsyslogd 2> /dev/null || true
/usr/bin/killall -HUP syslogd 2> /dev/null || true
' > etc/hysteria/.install.txt
sleep 1
chmod 0644 etc/hysteria/.install.txt
###############################################################################
cat << EOF > etc/hysteria/config.yaml.example
listen: :443
tls:
  cert: /path/to/cert.crt
  key: /path/to/privkey.pem
  sniGuard: strict
bandwidth:
  up: 10 gbps
  down: 10 gbps
auth:
  type: password
  password: new_password
resolver:
  type: udp
  tcp:
    addr: 127.0.0.1:53
    timeout: 4s
  udp:
    addr: 127.0.0.1:53
    timeout: 4s
sniff:
  enable: true 
  timeout: 2s 
  rewriteDomain: false 
  tcpPorts: 80,443
  udpPorts: all
outbounds:
  - name: v2ray
    type: socks5
    socks5:
      addr: 127.0.0.1:1080
masquerade:
  type: proxy
  proxy:
    url: https://www.example.com/
    rewriteHost: true
  listenHTTPS: :443
  forceHTTPS: true
EOF
###############################################################################

echo
sleep 2
tar -Jcvf /tmp/"hysteria-${_hysteria_version}-static.tar.xz" *
echo
sleep 2
cd /tmp
sha256sum "hysteria-${_hysteria_version}-static.tar.xz" > "hysteria-${_hysteria_version}-static.tar.xz".sha256
rm -fr /tmp/hysteria
rm -fr "${_tmp_dir}"
rm -fr /usr/local/go
rm -fr ~/.cache/go-build
sleep 2
echo
echo ' build hysteria done'
echo
exit

