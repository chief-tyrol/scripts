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

# Runs updates for a system using the `apt` package manager

set -o errexit
set -o nounset

if [ "${EUID:-1}" != '0' ]; then
  exec sudo -p "\`$(basename "${BASH_SOURCE[0]}")\` requires %U access, please enter password: " PATH="${PATH}" -s "${BASH_SOURCE[0]}" "${@}"
fi

# load additional functions (`load-bash-library.sh` must be on the PATH)
. load-bash-library.sh logging

function print_seperator() {
    echo "----------------------------------------"
}

log.info "Updating apt package index..."
print_seperator
apt update
echo ""
echo ""

log.info "Upgrading apt packages..."
print_seperator
apt upgrade -y
echo ""
echo ""

log.info "Performing distribution upgrade of apt packages..."
print_seperator
apt dist-upgrade -y
echo ""
echo ""

log.info "Cleaning apt cache"
print_seperator
apt autoremove -y
apt autoclean -y
apt clean -y
