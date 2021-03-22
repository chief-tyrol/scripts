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

# Links all Systemd files from a given directory into Systemd

set -o errexit
set -o nounset
set -o pipefail

if [ "${EUID:-1}" != '0' ]; then
  exec sudo -p "\`$(basename "${BASH_SOURCE[0]}")\` requires %U access, please enter password: " PATH="${PATH}" -s "${BASH_SOURCE[0]}" "${@}"
fi

function usage() {
  local -r name="$(basename "${BASH_SOURCE[0]}")"

  # abuse command substitution to assign heredoc to a variable
  docstring=$(cat <<-EOF
Usage: ${name} [folder]

Symlinks all Systemd files in "folder" into /etc/systemd/system

If "folder" is omitted, the current working directory is used
EOF
)
  # use `&& false` to ensure return code is `1`
  printf '%s\n' "${docstring}" >&2 && false
}

# parse input
case "${#}" in
  0) FOLDER="$(pwd)" ;;
  1) FOLDER="${1}"   ;;
  *) usage           ;;
esac

# load additional script function libraries
# "load-bash-library.sh" must be on the path
. load-bash-library.sh files

FOLDER="$(abspath "${FOLDER}")"

if [ ! -d "${FOLDER}" ]; then
  echo "Fatal: \"${FOLDER}\" is not a directory" >&2
  usage
fi

# every suffix a value systemd file can have
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
FILES=()

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

  unit_file="$(file_basename "${file}")"

  symlink="/etc/systemd/system/${unit_file}"

  if [ -h "${symlink}" ]; then
    # if file already exists but is a symlink, silently remove it
    rm -f "${symlink}"
  fi

  if [ -e "${symlink}" ]; then
    echo "Fatal: file \"${symlink}\" already exists and is not a symlink:" >&2
    ls -lah "${symlink}" >&2
    exit 1
  fi

  ln -s "${file}" "${symlink}"
  echo "linked \"${symlink}\" -> \"${file}\""

  FILES+=( "${unit_file}" )
done

# reload unit files
systemctl daemon-reload

echo "Installed the following files, be sure to run \"systemctl enable\" and/or \"systemctl start\" as needed:"

for file in "${FILES[@]}"; do
  echo "    ${file}"
done
