#!/bin/bash
cd "$(dirname "$0")"
tor/tor -f tor.conf >/dev/null 2>&1
exit
