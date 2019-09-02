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

# Runs "maven_clean_organization.sh" on all folders in a folder

set -o errexit
set -o nounset

DELEGATE='maven_clean_organization.sh'

if [ "${#}" == "0" ]; then
    FOLDER="$(pwd)"
elif [ "${#}" == "1" ]; then
    FOLDER="${1}"
else
    >&2 echo "Usage: ${BASH_SOURCE[0]} [folder]"
    exit 1
fi

# load additional script function libraries
# "load_script_library.sh" must be on the path
. load_script_library.sh files

FOLDER="$(abspath "${FOLDER}")"

if [ ! -d "${FOLDER}" ]; then
    >&2 echo "[ERROR] \"${FOLDER}\" is not a directory"
    exit 1
fi

iter=0
for file in "${FOLDER}/"*; do

  if [ ! -d "${file}" ]; then
    continue
  fi

  if [ "${iter}" -gt 0 ]; then
    echo ''
  fi

  "${DELEGATE}" "${file}"

  iter=$((iter + 1))
done
