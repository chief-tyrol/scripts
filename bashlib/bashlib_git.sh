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

#
#
# Script library - Git utilities

# load additional script function libraries
# "load_script_library.sh" must be on the path
. load_script_library.sh files

# Checks whether the current working directory is a git repository
#
# return : 0 if the directory is a git repo, 1 otherwise
function is_git_repo() {

    # git status returns success if the folder is a git repo, failure otherwise.
    # suppress all console output
    if git status 2>/dev/null 1>&2; then
      return 0
    fi

    return 1
}

# Checks whether the git repo in the current working directory
# contains any uncomitted changes. The response is undefined if
# the current working directory is not a git repository.
#
# return : 0 if there are local changes, 1 if there are none
function local_git_changes_exist() {

    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        return 0
    fi

    return 1
}

# prints the name of the active git branch for the current folder.
# if the current folder is not a git repository, prints nothing
function parse_git_branch_name() {
  git rev-parse --abbrev-ref --symbolic-full-name '@' 2>/dev/null
}

# prints the name of the remote tracking branch for the active git branch for the current folder.
# if the current folder is not a git repository, or there is no remote tracking branch, prints nothing
#
# https://stackoverflow.com/a/9753364
function parse_git_remote_branch_name() {
  git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null
}

# prints the name of the remote tracking branch for git branch given as the first argument.
# if the current folder is not a git repository, or there is no remote tracking branch for the given branch, prints nothing
#
# https://stackoverflow.com/a/9753364
function list_git_remote_branch_name() {
  git rev-parse --abbrev-ref --symbolic-full-name "${1}@{u}" 2>/dev/null
}

# https://stackoverflow.com/a/3278427
function compare_local_git_branch_with_remote() {
    DEFAULT='@{u}'
    UPSTREAM="${1:-${DEFAULT}}"
    results=$(git -c color.ui=false --no-optional-locks status -s -b --ahead-behind --untracked-files=no -- "${UPSTREAM}" 2>/dev/null | grep --color=none -e '\[*\]' | sed -E 's/^[^[]*\[([^]]+)\]/\1/')

    if [ -z "${results}" ]; then
        echo "in sync"
    else
        echo "${results}"
    fi
}
