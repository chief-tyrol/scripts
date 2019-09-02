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

# Runs updates

set -o errexit
set -o nounset

if [ "${USER:-}" != "root" ]; then
  echo "[WARNING] \"${0}\" must be run as root!"
  echo ""
  exec sudo "${0}"
fi

function print_seperator() {
    echo "----------------------------------------"
}

echo "Updating apt package index..."
print_seperator
apt update
echo ""
echo ""

echo "Upgrading apt packages..."
print_seperator
apt upgrade -y
echo ""
echo ""

echo "Performing distribution upgrade of apt packages..."
print_seperator
apt dist-upgrade -y
echo ""
echo ""

echo "Cleaning apt cache"
print_seperator
apt autoremove -y
apt autoclean -y
apt clean -y
echo ""
echo ""