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


#
# This script is still a WIP!
#

if [ "${#}" == "0" ]; then
    ROOT="$(pwd)"
elif [ "${#}" == "1" ]; then
    ROOT="${1}"
else
    echo "Usage: ${0} [folder]. If not provided, [folder] defaults to the current working directory"
    echo "If the given folder is a git repo, information about the repo is printed"
    exit 1
fi

# source script to get additional commands
. $(dirname "${0}")/git_commands.sh

ROOT=`abspath "$ROOT"`

if [ ! -d "${ROOT}" ]; then
    echo "[ERROR] \"${ROOT}\" is not a directory"
    exit 1
fi

cd "${ROOT}"

if [ "$(is_git_repo)" = "false" ]; then
    echo "[ERROR] \"${ROOT}\" is not a git repository"
    exit 1
fi

branch="$(parse_git_branch_name)"

remote="$(parse_git_remote_branch_name)"
remote_name=$(if [ -z "${remote}" ]; then echo "<no remote>"; else echo "${remote}"; fi)

if [ -n "${remote_name}" ]; then
    # force updates if there's a remote
    git fetch 1>&2 2>/dev/null
fi

remote_status="$(if [ -z "${remote}" ]; then echo "N/A"; else echo "$(compare_local_git_branch_with_remote)"; fi)"
changes=$(if [ "$(local_git_changes_exist)" = "true" ]; then echo "uncommitted local changes"; else echo "no uncommitted local changes"; fi )

echo "branch: ${branch}, remote: ${remote_name}, changes: ${changes}, remote status: ${remote_status}"