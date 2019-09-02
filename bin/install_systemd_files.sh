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

set -o errexit

if [ "${#}" == "0" ]; then
    FOLDER="$(pwd)"
elif [ "${#}" == "1" ]; then
    FOLDER="${1}"
else
    >&2 echo "Usage: ${BASH_SOURCE[0]} [folder]"
    >&2 echo "Symlinks all Systemd files in \"folder\" into /etc/systemd/system"
    >&2 echo "If \"folder\" is omitted, the current working directory is used"
    exit 1
fi

if [ "$(whoami)" != "root" ]; then
  echo "[WARNING] \"${BASH_SOURCE[0]}\" must be run as root!"
  echo ""
  exec sudo PATH="${PATH}" "${BASH_SOURCE[0]}" "${FOLDER}"
fi

# load additional script function libraries
# "load_script_library.sh" must be on the path
. load_script_library.sh basic

FOLDER="$(abspath "${FOLDER}")"

if [ ! -d "${FOLDER}" ]; then
  echo "Fatal: \"${FOLDER}\" is not a directory"
  exit 1
fi

# list of value file suffixes to use
SUFFICES=(
  'service'
  'device'
  'timer'
  'mount'
  'swap'
  'automount'
  'slice'
  'path'
  'target'
  'socket'
)

for file in "${FOLDER}/"*; do
  file="$(abspath "${file}")"

  extension="$(file_extension "${file}")"

  if [ -z "${extension}" ]; then
    echo "Ignoring \"${file}\", no file extension"
    continue
  fi

  found='false'

  for suffix in "${SUFFICES[@]}"; do
    if [ "${extension}" == "${suffix}" ]; then
      found='true'
      break
    fi
  done

  if [ "${found}" != "true" ]; then
    echo "Ignoring \"${file}\", unsupported file extension \".${extension}\""
    continue
  fi

  symlink="/etc/systemd/system/$(file_basename "${file}")"

  if [ -h "${symlink}" ]; then
    # if file already exists but is a symlink, silently remove it
    rm -f "${symlink}"
  fi

  if [ -e "${symlink}" ]; then
    echo "Fatal: file \"${symlink}\" already exists and is not a symlink:"
    ls -lah "${symlink}"
    exit 1
  fi

  ln -s "${file}" "${symlink}"
  echo "linked \"${symlink}\" -> \"${file}\""
done

# reload unit files
systemctl daemon-reload
