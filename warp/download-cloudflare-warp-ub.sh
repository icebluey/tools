#!/bin/bash
set -e
case "${1}" in
  2004|20.04)
    _distro="focal"
    _dir="20.04"
    ;;
  2204|22.04)
    _distro="jammy"
    _dir="22.04"
    ;;
  2404|24.04)
    _distro="noble"
    _dir="24.04"
    ;;
  *)
    _distro="jammy"
    _dir="22.04"
    ;;
esac

cloudflare_warp_ver=$(curl -s "https://pkg.cloudflareclient.com/dists/${_distro}/main/binary-amd64/Packages" \
  | grep -E -o 'Version: [0-9]+\.[0-9]+\.[0-9]+' \
  | head -n1 \
  | grep -E -o '[0-9]+\.[0-9]+\.[0-9]+')

cloudflare_warp_filepath=$(curl -s "https://pkg.cloudflareclient.com/dists/${_distro}/main/binary-amd64/Packages" \
  | grep -i 'Filename:' \
  | head -n1 \
  | awk -F: '{print $2}' | sed 's|[ \t]*||g')

echo "Downloading Cloudflare warp ${cloudflare_warp_ver}:"
mkdir "${_dir}"
cd "${_dir}"
wget -c -t 9 -T 9 "https://pkg.cloudflareclient.com/${cloudflare_warp_filepath}"
echo "Completed"
exit
#############################################################################

https://pkg.cloudflareclient.com/pool/noble/main/c/cloudflare-warp/cloudflare-warp_2025.8.779.0_amd64.deb
https://pkg.cloudflareclient.com/pool/jammy/main/c/cloudflare-warp/cloudflare-warp_2025.8.779.0_amd64.deb
https://pkg.cloudflareclient.com/pool/focal/main/c/cloudflare-warp/cloudflare-warp_2025.8.779.0_amd64.deb

https://pkg.cloudflareclient.com/pool/focal/main/c/cloudflare-warp/cloudflare-warp_2024.6.497-1_amd64.deb
https://pkg.cloudflareclient.com/pool/focal/main/c/cloudflare-warp/cloudflare-warp_2024.11.150.0_amd64.deb

https://pkg.cloudflareclient.com/pool/jammy/main/c/cloudflare-warp/cloudflare-warp_2024.6.497-1_amd64.deb
https://pkg.cloudflareclient.com/pool/jammy/main/c/cloudflare-warp/cloudflare-warp_2024.11.150.0_amd64.deb

# el8/9
https://pkg.cloudflareclient.com/rpm/x86_64/cloudflare-warp-2025.8.779.0.x86_64.rpm
https://pkg.cloudflareclient.com/rpm/x86_64/cloudflare-warp-2025.2.600.0.x86_64.rpm
https://pkg.cloudflareclient.com/rpm/x86_64/cloudflare-warp-2024.12.554.0.x86_64.rpm
https://pkg.cloudflareclient.com/rpm/x86_64/cloudflare-warp-2024.11.309.0.x86_64.rpm
https://pkg.cloudflareclient.com/rpm/x86_64/cloudflare-warp-2024.11.150.0.x86_64.rpm

# old
https://pkg.cloudflareclient.com/rpm/x86_64/cloudflare-warp-2024.6.497-1.x86_64.rpm

https://pkg.cloudflareclient.com/rpm/aarch64/cloudflare-warp-2024.11.309.0.aarch64.rpm


wget -c "https://pkg.cloudflareclient.com/pool/focal/main/c/cloudflare-warp/cloudflare-warp_2025.6.1335.0_amd64.deb"
wget -c "https://pkg.cloudflareclient.com/pool/jammy/main/c/cloudflare-warp/cloudflare-warp_2025.6.1335.0_amd64.deb"
wget -c "https://pkg.cloudflareclient.com/pool/noble/main/c/cloudflare-warp/cloudflare-warp_2025.6.1335.0_amd64.deb"
wget -c "https://pkg.cloudflareclient.com/rpm/x86_64/cloudflare-warp-2025.6.1335.0.x86_64.rpm"

