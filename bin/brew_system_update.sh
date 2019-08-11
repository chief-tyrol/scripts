#!/usr/bin/env bash
#
#    MIT License
#
#    Copyright (c) 2019 Tyrol
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

# Updates packages managed by Homebrew
# https://brew.sh/

function print_seperator() {
    echo "----------------------------------------"
}

print_seperator
echo "Homebrew version:"
brew --version

echo ""
print_seperator
echo "Homebrew configuration:"
brew config

echo ""
print_seperator
echo "Updating Homebrew..."
brew update

echo ""
print_seperator
echo "Upgrading Homebrew..."
brew upgrade

echo ""
print_seperator
echo "Running cleanup..."
brew cleanup

echo ""
print_seperator
echo "Homebrew configuration after upgrades:"
brew config
