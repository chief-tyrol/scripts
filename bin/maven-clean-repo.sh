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
. load-bash-library.sh files logging

FOLDER="$(abspath "${FOLDER}")"

if [ ! -d "${FOLDER}" ]; then
    >&2 echo "[ERROR] \"${FOLDER}\" is not a directory"
    exit 1
fi

_OTHER_MAVEN_FILES=(
    pom.xml.bak
    pom.xml.tag
    pom.xml.releaseBackup
    pom.xml.versionsBackup
    pom.xml.next
    dependency-reduced-pom.xml
    dependency-reduced-pom.xml.bak
    release.properties
)

INDENT_STR="$(repeat_string " " "${INDENT:-0}")"

cd "${FOLDER}" || exit 1

# skip non-maven folders
if [ ! -e 'pom.xml' ]; then
  exit 0
fi

name="$(file_basename "${FOLDER}")"

printf '%s\e[34;1mCleaning \e[39m"%s"\e[34m...\e[0m ' "${INDENT_STR}" "${name}"

# run the actual maven clean
if ! mvn clean >/dev/null 2>&1; then
  printf '\e[31;1mFAILURE\e[0m:\n'
  printf '"mvn clean" failed\n'
  exit 1
fi

# clear out any other cruft maven files that may have accumulated
for file in "${_OTHER_MAVEN_FILES[@]}"; do
    if ! find . -name "${file}" -delete; then
      printf '\e[31;1mFAILURE\e[0m:\n'
      printf '%sThe "find" command failed while attempting to delete "%s"\n' "${INDENT_STR}" "${file}"
      exit 1
    fi
done

printf '\e[32;1msuccess!\e[0m\n'
