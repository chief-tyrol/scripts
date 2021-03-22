#!/usr/bin/env bash
#
#    MIT License
#
#    Copyright (c) 2019 Gryphon Zone
#
#    Permission is hereby granted, free of charge, to any person obtaining a copy
#    of this software and associated documentation files (the "Software"), to deal
#    in the Software without restriction, including without limitation the rights
#    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#    copies of the Software, and to permit persons to whom the Software is
#    furnished to do so, subject to the following conditions:
#
#    The above copyright notice and this permission notice shall be included in all
#    copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#    SOFTWARE.


# Script for adding bluray support to VLC on linux, based on https://askubuntu.com/a/579156
#
# If needed, makemv forum post for license key: https://www.makemkv.com/forum/viewtopic.php?f=5&t=1053

set -o errexit
set -o nounset
set -o pipefail

if [ "${EUID:-1}" != '0' ]; then
  exec sudo -p "\`$(basename "${BASH_SOURCE[0]}")\` requires %U access, please enter password: " PATH="${PATH}" -s "${BASH_SOURCE[0]}" "${@}"
fi

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
cd "$(dirname "$(locate libmmbd.so.0 | head -n 1)")" || exit 1

# create symlinks for VLC to use
if [ ! -f "libaacs.so.0" ]; then
    ln -s libmmbd.so.0 libaacs.so.0
fi

if [ ! -f "libbdplus.so.0" ]; then
    ln -s libmmbd.so.0 libbdplus.so.0
fi

{ set +x; } 2> /dev/null
