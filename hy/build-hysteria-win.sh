#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
/sbin/ldconfig

_install_7z() {
    set -e
    _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    _7zip_loc=$(wget -qO- 'https://www.7-zip.org/download.html' | grep -i '\-linux-x64.tar' | grep -i 'href="' | sed 's|"|\n|g' | grep -i '\-linux-x64.tar' | sort -V | tail -n 1)
    _7zip_ver=$(echo ${_7zip_loc} | sed -e 's|.*7z||g' -e 's|-linux.*||g')
    wget -c -t 9 -T 9 "https://www.7-zip.org/${_7zip_loc}"
    sleep 1
    tar -xof *.tar*
    sleep 1
    rm -f *.tar*
    rm -f /usr/bin/7z
    rm -f /usr/local/bin/7z
    install -v -c -m 0755 7zzs /usr/bin/7z
    sleep 1
    cd /tmp
    rm -fr "${_tmp_dir}"
}

_install_go() {
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
_install_7z
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
rm -fr ~/.config/go
echo
go version
echo
_tmp_dir="$(mktemp -d)"
cd "${_tmp_dir}"
tar -xof /tmp/hysteria*src.tar.gz

cd hysteria*
for dir in core app extras; do
    cd $dir
    go mod tidy || true
    cd ..
done
export HY_APP_PLATFORMS="windows/amd64-avx"
python3 hyperbole.py build -r
/bin/ls -l build/hysteria-windows-amd64-avx.exe
cp -f build/hysteria-windows-amd64-avx.exe /tmp/
sleep 1
cd /tmp
/usr/bin/7z -tzip a hysteria-windows-amd64-avx.exe.zip hysteria-windows-amd64-avx.exe

rm -fr /tmp/hysteria
mkdir /tmp/hysteria
mv -f /tmp/hysteria*.zip /tmp/hysteria/
mv -f /tmp/hysteria*.tar* /tmp/hysteria/
rm -fr "${_tmp_dir}"
rm -fr /usr/local/go
rm -fr ~/.cache/go-build
sleep 2
echo
echo ' build hysteria-windows done'
echo
exit

