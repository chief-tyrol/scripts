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

DELEGATE="git_update_repo.sh"

if [ "${#}" == "0" ]; then
    FOLDER="$(pwd)"
elif [ "${#}" == "1" ]; then
    FOLDER="${1}"
else
    >&2 echo "Usage: ${BASH_SOURCE[0]} [folder]"
    exit 1
fi

#>&2 echo "Usage: ${0} [parent folder]"
#>&2 echo "Update all git repositories which are subdirectories of [parent folder]."
#>&2 echo "If [parent folder] is not provided, it defaults to the current working directory."
#>&2 echo ""
#>&2 echo "An \"update\" is defined running a \"git pull\", \"git fetch --prune\", and \"git gc\"."
#>&2 echo ""
#>&2 echo "e.g, if your git folder layout looked like:"
#>&2 echo ""
#>&2 echo "  git"
#>&2 echo "   \-organization"
#>&2 echo "     \-repo1"
#>&2 echo "     \-repo2"
#>&2 echo ""
#>&2 echo "then you could run ${0} \"git/organization\" to update both repos"
#exit 1

# load additional script function libraries
# "load_script_library.sh" must be on the path
. load_script_library.sh files git

function print_seperator() {
    echo '----------------------------------------'
}

FOLDER="$(abspath "${FOLDER}")"

if [ ! -d "${FOLDER}" ]; then
    >&2 echo "[ERROR] \"${FOLDER}\" is not a directory"
    exit 1
fi

print_seperator
printf 'Updating git repos under \"\e[1m%s\e[0m\"\n' "${FOLDER}"
print_seperator

for folder in "${FOLDER}"/*; do

    if [ ! -d "${folder}" ]; then
        # skip non-folders
        continue
    fi

    "${DELEGATE}" "${folder}"

    print_seperator

done
