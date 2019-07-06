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
    echo "Usage: ${0} [folder]"
    echo "Update all git projects in subfolders of [folder]. If [folder] is not provided, it defaults to the current working directory"
    echo "e.g, if your git folder layout looked like:"
    echo ""
    echo "  git"
    echo "   \-organization"
    echo "     \-repo1"
    echo "     \-repo2"
    echo ""
    echo "then you could run ${0} \"git/organization\" to update both repos"
    exit 1
fi

# source script to get additional commands
. $(dirname "${0}")/git_commands.sh

ROOT=`abspath "$ROOT"`
IFS=$'\n'

if [ ! -d "${ROOT}" ]; then
    echo "[ERROR] \"${ROOT}\" is not a directory"
    exit 1
fi

seperator
echo "Updating all git repos in subfolders of \"${ROOT}\""

for folder in `ls -1 "${ROOT}"`; do

    # make sure we start in the correct directory
    cd "${ROOT}"

    if [ ! -d "${folder}" ]; then
        # skip non-folders
        continue
    fi

    cd "${folder}"

    if [ "$(is_git_repo)" != "true" ]; then
        # skip non-repos
        continue
    fi

    # get the branch
    branch=`parse_git_branch_name`

    seperator
    echo "Updating \"${folder}\" (currently on branch ${branch})"

    if [ "$(local_git_changes_exist)" == 'false' ]; then
        echo -n "Working directory clean, performing \`git pull\`... "

        output=$(git pull 2>&1)

        if [ "${?}" != "0" ]; then
            echo "failed!"
            echo "error performing \`git pull\`, console output:"
            echo "${output}"
        else
            echo 'done!'
        fi
    fi

    echo -n "Performing \`git fetch\`... "

    # always do a git fetch (even if the working copy is dirty) in order to prune dead remote branches
    output=$(git fetch --prune 2>&1)

    if [ "${?}" != "0" ]; then
        echo "failed!"
        echo "error performing \`git fetch\`, console output:"
        echo "${output}"
    else
        echo 'done!'
    fi

    echo -n "Performing \`git gc\`... "

    # always do a git gc in order to clean repos
    output=$(git gc 2>&1)

    if [ "${?}" != "0" ]; then
        echo "failed!"
        echo "error performing \`git gc\`, console output:"
        echo "${output}"
    else
        echo 'done!'
    fi

done
