#!/usr/bin/env bash
#
# Script for adding bluray support to VLC on linux, based on https://askubuntu.com/a/579156
#
# If needed, makemv forum post for license key: https://www.makemkv.com/forum/viewtopic.php?f=5&t=1053
#

if [ "${USER:-}" != "root" ]; then
  echo "[WARNING] \"${0}\" must be run as root!"
  exec sudo "${0}"
fi

set -x

# remove open source libraries, since they conflict
apt remove -y libaacs0 libbdplus0

# Add PPA
add-apt-repository -y ppa:heyarje/makemkv-beta
apt update

# install closed-source codecs
apt install -y makemkv-bin makemkv-oss

# update search index
updatedb

# locate installed DLL
cd $(dirname $(locate libmmbd.so.0 | head -n 1))

# create symlinks for VLC to use
if [ ! -f "libaacs.so.0" ]; then
    ln -s libmmbd.so.0 libaacs.so.0
fi

if [ ! -f "libbdplus.so.0" ]; then
    ln -s libmmbd.so.0 libbdplus.so.0
fi

{ set +x; } 2> /dev/null
