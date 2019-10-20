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

#
# Script based on https://stackoverflow.com/a/1116890

set -o errexit
set -o nounset

TARGET_FILE="${1:-}"

if [[ -z "${TARGET_FILE}" || "${TARGET_FILE}" == "-h" || "${TARGET_FILE}" == "--help" ]]; then
  >&2 echo "Usage: ${BASH_SOURCE[0]} file"
  >&2 echo ""
  >&2 echo "BSD compatible equivalent to \`readlink -f\` (e.g. for use on OSX)."
  exit 1
fi

cd "$(dirname "${TARGET_FILE}")" || exit 1
TARGET_FILE="$(basename "${TARGET_FILE}")"

# Iterate down a (possible) chain of symlinks
while [ -L "$TARGET_FILE" ]; do
    TARGET_FILE="$(readlink "${TARGET_FILE}")"
    cd "$(dirname "${TARGET_FILE}")" || exit 1
    TARGET_FILE=$(basename "${TARGET_FILE}")
done

# Compute the canonicalized name by finding the physical path
# for the directory we're in and appending the target file.
PHYS_DIR="$(pwd -P)"
RESULT="${PHYS_DIR}/${TARGET_FILE}"
echo "${RESULT}"
