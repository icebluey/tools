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

    # go1.25.X
    _go_version="$(wget -qO- 'https://golang.org/dl/' | grep -i 'linux-amd64\.tar\.' | sed 's/"/\n/g' | grep -i 'linux-amd64\.tar\.' | cut -d/ -f3 | grep -i '\.gz$' | sed 's/go//g; s/.linux-amd64.tar.gz//g' | grep -ivE 'alpha|beta|rc' | sort -V | uniq | grep '^1\.25\.' | tail -n 1)"
    wget -q -c -t 0 -T 9 "https://dl.google.com/go/go${_go_version}.linux-amd64.tar.gz"
    rm -fr /usr/local/go
    install -m 0755 -d /usr/local/go
    tar -xof "go${_go_version}.linux-amd64.tar.gz" --strip-components=1 -C /usr/local/go/
    cd /tmp
    rm -fr "${_tmp_dir}"
}
set -e
rm -fr /tmp/v2ray
rm -fr /tmp/v2ray*.tar*

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
git clone --recursive 'https://github.com/v2fly/v2ray-core.git' v2ray-core
sleep 1
cp -afr v2ray-core "v2ray-core-$(date -u +%Y%m%d)-src"
tar -zcf "v2ray-core-$(date -u +%Y%m%d)-src".tar.gz "v2ray-core-$(date -u +%Y%m%d)-src"
sleep 1
mv -f "v2ray-core-$(date -u +%Y%m%d)-src".tar.gz /tmp/
rm -fr "v2ray-core-$(date -u +%Y%m%d)-src"

cd v2ray-core
go mod tidy
rm -fr .git 
###############################################################################

_build_date="$(date --utc +"%a %b %_d %T %Y UTC")"
sed "/build .*= /a\\\tbuilt    = \"Built on: ${_build_date}\"" -i core.go
sed '/serial.Concat("V2Ray "/a\\t\tbuilt,' -i core.go
head -n 40 core.go
echo

rm -fr /tmp/v2ray
install -m 0755 -d /tmp/v2ray/etc/v2ray
install -m 0755 -d /tmp/v2ray/usr/bin

cd main
CGO_ENABLED=0 GOARCH=amd64 GOAMD64=v3 go build -trimpath -ldflags "-s -w" -o /tmp/v2ray/usr/bin/v2ray

cd /tmp/v2ray
###############################################################################
echo '[Unit]
Description=V2Ray Service
After=network.target
Wants=network.target

[Service]
# This service runs as root. You may consider to run it as another user for security concerns.
# By uncommenting the following two lines, this service will run as user v2ray/v2ray.
# More discussion at https://github.com/v2ray/v2ray-core/issues/1011
# User=v2ray
# Group=v2ray
Type=simple
PIDFile=/run/v2ray.pid
AmbientCapabilities=CAP_NET_BIND_SERVICE
ExecStart=/usr/bin/v2ray run -config /etc/v2ray/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target' > etc/v2ray/v2ray.service
sleep 1
chmod 0644 etc/v2ray/v2ray.service
###############################################################################
cat << EOF > etc/v2ray/v2ray.logrotate
/var/log/v2ray/*log {
    create 0640 syslog adm
    daily
    rotate 1
    missingok
    notifempty
    compress
    sharedscripts
    postrotate
        /usr/bin/killall -HUP rsyslogd 2>/dev/null || true
        /usr/bin/killall -HUP syslogd 2>/dev/null || true
    endscript
}
EOF
###############################################################################
cat << EOF > etc/v2ray/v2ray.rsyslog
:programname, startswith, "v2ray" {
    /var/log/v2ray/v2ray.log
    stop
}
EOF
###############################################################################
echo '
cd "$(dirname "$0")"
/bin/rm -f /lib/systemd/system/v2ray.service
[ -f /etc/logrotate.d/v2ray ] || install -m 0644 v2ray.logrotate /etc/logrotate.d/v2ray
[ -f /etc/rsyslog.d/10-v2ray.conf ] || install -m 0644 v2ray.rsyslog /etc/rsyslog.d/10-v2ray.conf
[ -d /var/log/v2ray ] || install -m 0777 -d /var/log/v2ray
chmod 0777 /var/log/v2ray
/usr/bin/install -v -c -m 0644 v2ray.service /lib/systemd/system/v2ray.service
/bin/systemctl daemon-reload >/dev/null 2>&1 || : 
/usr/bin/killall -HUP rsyslogd 2>/dev/null || true
/usr/bin/killall -HUP syslogd 2>/dev/null || true
' > etc/v2ray/.install.txt
sleep 1
chmod 0644 etc/v2ray/.install.txt
###############################################################################
cat << EOF > etc/v2ray/config.json.example
{
  "log": {
    "access": "",
    "error": "",
    "loglevel": "none"
  },
  "inbounds": [
    {
      "port": 1080,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      },
      "settings": {
        "auth": "noauth",
        "udp": true,
        "allowTransparent": false
      }
    },
    {
      "port": 1081,
      "listen": "127.0.0.1",
      "protocol": "http",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      },
      "settings": {
        "auth": "noauth",
        "udp": true,
        "allowTransparent": false
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "socks",
      "tag": "warp",
      "settings": {
        "servers": [
          {
            "address": "127.0.0.1",
            "port": 10005,
            "users": []
          }
        ]
      }
    }
  ],
  "dns": {
    "servers": [
      "127.0.0.1",
      "localhost"
    ]
  },
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "domain": [
          "recaptcha.net",
          "hcaptcha.com"
        ],
        "outboundTag": "warp"
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "network": "udp,tcp"
      }
    ]
  }
}
EOF
###############################################################################

_date="$(date -u +%Y%m%d)"
_version="$(./usr/bin/v2ray version 2>&1 | grep '^V2Ray ' | awk '{print $2}')"
echo
sleep 2
tar -Jcvf /tmp/"v2ray-${_version}-${_date}-static.tar.xz" *
echo
sleep 2
cd /tmp
sha256sum "v2ray-${_version}-${_date}-static.tar.xz" > "v2ray-${_version}-${_date}-static.tar.xz".sha256

rm -fr /tmp/v2ray
install -m 0755 -d /tmp/v2ray
mv -f /tmp/v2ray*.tar* /tmp/v2ray/

rm -fr "${_tmp_dir}"
rm -fr /usr/local/go
rm -fr ~/.cache/go-build
sleep 2
echo
echo ' build v2ray done'
echo
exit

