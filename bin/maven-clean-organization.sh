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
set -o nounset
set -o pipefail

function usage() {
  local -r name="$(basename "${BASH_SOURCE[0]}")"

  # abuse command substitution to assign heredoc to a variable
  docstring=$(cat <<-EOF
Usage: ${name} [folder]

TODO documentation
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

# load additional functions (`load-bash-library.sh` must be on the PATH)
. load-bash-library.sh files strings

FOLDER="$(abspath "${FOLDER}")"

if [ ! -d "${FOLDER}" ]; then
    >&2 echo "Fatal: \"${FOLDER}\" is not a directory"
    exit 1
fi

name="$(file_basename "${FOLDER}")"

printf "Cleaning Maven projects under \"\e[1m%s\e[0m\"...\n" "${FOLDER}"

for folder in "${FOLDER}"/*; do

    if [ ! -d "${folder}" ]; then
        # not a folder, ignore
        continue
    fi

    INDENT="2" maven-clean-repo.sh "${folder}"
done

printf 'Cleaned Maven projects under "%s"\n' "${name}"
