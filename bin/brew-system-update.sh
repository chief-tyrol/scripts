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

# Runs updates for a system using the `brew` package manager
# https://brew.sh/

set -o errexit
set -o nounset
set -o pipefail

function print_seperator() {
    echo "----------------------------------------"
}

echo "Current Homebrew configuration:"
print_seperator
brew config
echo ""
echo ""

echo "Updating Homebrew package index..."
print_seperator
brew update
echo ""
echo ""

echo "Upgrading Homebrew packages..."
print_seperator
brew upgrade
echo ""
echo ""

echo "Running Homebrew cleanup..."
print_seperator
brew cleanup
echo ""
echo ""

echo "Updated Homebrew configuration:"
print_seperator
brew config
echo ""
echo ""

echo "Installed packages:"
print_seperator
brew list
echo ''
echo ''
