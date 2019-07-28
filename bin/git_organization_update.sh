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
. load_script_library.sh basic git

function print_seperator() {
    echo "----------------------------------------"
}

ROOT="$(abspath "${ROOT}")"

if [ ! -d "${ROOT}" ]; then
    >&2 echo "[ERROR] \"${ROOT}\" is not a directory"
    exit 1
fi

print_seperator
echo "Updating all git repos in subfolders of \"${ROOT}\""
print_seperator

for folder in "${ROOT}"/*; do

    if [ ! -d "${folder}" ]; then
        # skip non-folders
        continue
    fi

    cd "${folder}" || exit 1

    if [ "$(is_git_repo)" != "true" ]; then
        # skip non-repos
        continue
    fi

    # get the branch name
    branch="$(parse_git_branch_name)"

    echo "\"$(basename "${folder}")\" being updated (active branch: ${branch})"

    if [ "$(local_git_changes_exist)" == 'false' ]; then
        echo -n 'Running "git pull"...  '

        if ! output=$(git pull 2>&1); then
            echo 'FAILED:'
            echo "${output}"
        else
            echo 'done!'
        fi
    else
        echo 'Uncommitted files, skipping "git pull"'
    fi

    echo -n 'Running "git fetch"... '

    # always do a git fetch (even if the working copy is dirty) in order to prune dead remote branches
    if ! output=$(git fetch --prune 2>&1); then
        echo 'FAILED:'
        echo "${output}"
    else
        echo 'done!'
    fi

    echo -n 'Running "git gc"...    '

    # always do a git gc in order to clean repos
    if ! output=$(git gc 2>&1); then
        echo 'FAILED:'
        echo "${output}"
    else
        echo 'done!'
    fi

    print_seperator

done
