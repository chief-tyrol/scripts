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

# Restarts the audio daemon on a mac, which will usually fix audio issues

set -o errexit
set -o nounset
set -o pipefail

PROCESS='coreaudiod'
COMMAND="/usr/sbin/${PROCESS}"

# TODO refactor to use pgrep
AUDIO_PID="$(ps -ef | grep "${COMMAND}" | grep -v grep | awk '{print $2}' | tr -c -d '0123456789')"

if [ -z "${AUDIO_PID}" ]; then
  >&2 echo "FATAL: unable to determine pid for ${PROCESS}"
  exit 1
fi

echo "Please enter password to kill process \"${AUDIO_PID}\":"
sudo kill "${AUDIO_PID}"