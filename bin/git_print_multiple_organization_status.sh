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

DELEGATE="git_print_organization_status.sh"

if [ "${#}" == "0" ]; then
    ROOT="$(pwd)"
elif [ "${#}" == "1" ]; then
    ROOT="${1}"
else
    >&2 echo "Usage: ${0} [parent folder]"
    >&2 echo "Update all git repositories which are subdirectories of [parent folder]."
    >&2 echo "If [parent folder] is not provided, it defaults to the current working directory."
    >&2 echo ""
    >&2 echo "An \"update\" is defined running a \"git pull\", \"git fetch --prune\", and \"git gc\"."
    >&2 echo ""
    >&2 echo "e.g, if your git folder layout looked like:"
    >&2 echo ""
    >&2 echo "  git"
    >&2 echo "   \-organization"
    >&2 echo "     \-repo1"
    >&2 echo "     \-repo2"
    >&2 echo ""
    >&2 echo "then you could run ${0} \"git/organization\" to update both repos"
    exit 1
fi

# load additional script function libraries
# "load_script_library.sh" must be on the path
. load_script_library.sh basic

ROOT="$(abspath "${ROOT}")"

if [ ! -d "${ROOT}" ]; then
    echo "[ERROR] \"${ROOT}\" is not a directory"
    exit 1
fi

for folder in "${ROOT}"/*; do

    if [ ! -d "${folder}" ]; then
        # skip non-folders
        continue
    fi

    echo ''
    "${DELEGATE}" "${folder}"
done