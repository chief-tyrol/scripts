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

if [ "${#}" == "0" ]; then
    FOLDER="$(pwd)"
elif [ "${#}" == "1" ]; then
    FOLDER="${1}"
else
    >&2 echo "Usage: ${BASH_SOURCE[0]} [folder]"
    exit 1
fi

# load additional script function libraries
# "load_script_library.sh" must be on the path
. load_script_library.sh files git

FOLDER="$(abspath "${FOLDER}")"

if [ ! -d "${FOLDER}" ]; then
    >&2 echo "Fatal: \"${FOLDER}\" is not a directory"
    exit 1
fi

cd "${FOLDER}" || exit 1

# skip non-repos
if ! is_git_repo; then
  printf '\e[33mIgnoring "\e[1m%s\e[0m\e[33m", not a git repository\e[0m\n' "$(basename "${FOLDER}")"
  exit 0
fi

# get the branch name
branch="$(parse_git_branch_name)"

printf "Updating \"\e[1m%s\e[0m\" (branch: \"\e[1m%s\e[0m\")\n" "$(basename "${FOLDER}")" "${branch}"

if ! local_git_changes_exist; then
    printf '\e[34mRunning  "git pull"...  \e[0m'

    if ! output=$(git pull 2>&1); then
        printf '\e[31mFAILED:\e[0m\n'
        echo "${output}"
    else
        printf '\e[32mdone!\e[0m\n'
    fi
else
    printf '\e[33mSkipping "git pull", \e[1muncommitted changes present\e[0m\n'
fi

printf '\e[34mRunning  "git fetch"... \e[0m'

# always do a git fetch (even if the working copy is dirty) in order to prune dead remote branches
if ! output=$(git fetch --prune 2>&1); then
    printf '\e[31mFAILED:\e[0m\n'
    echo "${output}"
else
    printf '\e[32mdone!\e[0m\n'
fi

printf '\e[34mRunning  "git gc"...    \e[0m'

# always do a git gc in order to clean repos
if ! output=$(git gc 2>&1); then
    printf '\e[31mFAILED:\e[0m\n'
    echo "${output}"
else
    printf '\e[32mdone!\e[0m\n'
fi
