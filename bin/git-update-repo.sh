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
. load-bash-library.sh files git

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

# handle differences in BSD/GNU xargs implementation
if [ -n "$(uname -a | grep -i darwin)" ]; then
  XARG_ARG=''
else
  XARG_ARG='--no-run-if-empty'
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


# always do a git fetch (even if the working copy is dirty) in order to prune dead remote branches
printf '\e[34mRunning  "git fetch"... \e[0m'
if ! output=$(git fetch --all --prune --prune-tags 2>&1); then
    printf '\e[31mFAILED:\e[0m\n'
    echo "${output}"
else
    printf '\e[32mdone!\e[0m\n'
fi

# deletes all local branches which are set up to track a remote branch,
# where the remote branch has been deleted.
printf '\e[34mRunning  git cleanup... \e[0m'
if ! output="$( git branch -r | awk '{print $1}' | grep -E -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs ${XARG_ARG} git branch -D )"; then
    printf '\e[31mFAILED:\e[0m\n'
    echo "${output}"
else
    printf '\e[32mdone!\e[0m\n'
fi

# force a git prune to cleanup cruft (usually a `git gc` will do this, however there are corner cases)
printf '\e[34mRunning  "git prune"... \e[0m'
if ! output=$(git prune 2>&1); then
    printf '\e[31mFAILED:\e[0m\n'
    echo "${output}"
else
    printf '\e[32mdone!\e[0m\n'
fi

# always do a git gc in order to clean repos
printf '\e[34mRunning  "git gc"...    \e[0m'
if ! output=$(git gc 2>&1); then
    printf '\e[31mFAILED:\e[0m\n'
    echo "${output}"
else
    printf '\e[32mdone!\e[0m\n'
fi

