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

DELEGATE="git_print_repo_status.sh"

if [ "${#}" == "0" ]; then
    ROOT="$(pwd)"
elif [ "${#}" == "1" ]; then
    ROOT="${1}"
else
    echo "Usage: ${0} [parent folder]"
    echo "Update all git repositories which are subdirectories of [parent folder]."
    echo "If [parent folder] is not provided, it defaults to the current working directory."
    echo ""
    echo "An \"update\" is defined running a \"git pull\", \"git fetch --prune\", and \"git gc\"."
    echo ""
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

function seperator() {
    echo "----------------------------------------"
}

# load additional script function libraries
# "load_script_library.sh" must be on the path
. load_script_library.sh basic git math strings

ROOT=`abspath "$ROOT"`
IFS=$'\n'

if [ ! -d "${ROOT}" ]; then
    echo "[ERROR] \"${ROOT}\" is not a directory"
    exit 1
fi

placeholder=''
COLUMN_1=('Organization' "${placeholder}")
REPOS=('Repository' "${placeholder}")
CHANGES=('Uncommitted Changes' "${placeholder}")
BRANCHES=('Branch' "${placeholder}")
REMOTES=('Tracking' "${placeholder}")
REMOTE_STATUSES=('Commit Delta With Remote' "${placeholder}")

# initialize variables
COLUMN_1_STRLEN='0'
MAX_REPO_STR_LEN='0'
CHANGES_STR_LEN='0'
BRANCHES_STR_LEN='0'
REMOTES_STR_LEN='0'
REMOTE_STATUSES_STR_LEN='0'

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
    COLUMN_1+=("$(basename "${ROOT}")")
    REPOS+=("${folder}")

    changes=$(if [ "$(local_git_changes_exist)" == "true" ]; then echo "exist"; else echo "none"; fi )
    CHANGES+=("${changes}")

    BRANCHES+=("$(parse_git_branch_name)")

    remote="$(parse_git_remote_branch_name)"

    if [ -z "${remote}" ]; then
        REMOTES+=('none')
        REMOTE_STATUSES+=('N/A')
    else
        REMOTES+=("${remote}")
        REMOTE_STATUSES+=("$(compare_local_git_branch_with_remote)")
    fi
done

# calculate the longest line in each column
for i in $(seq 0 1 $(( ${#REPOS[@]} - 1)) ); do
    COLUMN_1_STRLEN=$(max "${COLUMN_1_STRLEN}" $(strlen "${COLUMN_1[${i}]}"))
    MAX_REPO_STR_LEN=$(max "${MAX_REPO_STR_LEN}" $(strlen "${REPOS[${i}]}"))
    CHANGES_STR_LEN=$(max "${CHANGES_STR_LEN}" $(strlen "${CHANGES[${i}]}"))
    BRANCHES_STR_LEN=$(max "${BRANCHES_STR_LEN}" $(strlen "${BRANCHES[${i}]}"))
    REMOTES_STR_LEN=$(max "${REMOTES_STR_LEN}" $(strlen "${REMOTES[${i}]}"))
    REMOTE_STATUSES_STR_LEN=$(max "${REMOTE_STATUSES_STR_LEN}" $(strlen "${REMOTE_STATUSES[${i}]}"))
done

# now that we know the size of each column, add the sub-header separators
COLUMN_1[1]=$(repeat_string '-' ${COLUMN_1_STRLEN})
REPOS[1]=$(repeat_string '-' ${MAX_REPO_STR_LEN})
CHANGES[1]=$(repeat_string '-' ${CHANGES_STR_LEN})
BRANCHES[1]=$(repeat_string '-' ${BRANCHES_STR_LEN})
REMOTES[1]=$(repeat_string '-' ${REMOTES_STR_LEN})
REMOTE_STATUSES[1]=$(repeat_string '-' ${REMOTE_STATUSES_STR_LEN})

COLUMN_1+=("${COLUMN_1[1]}")
REPOS+=("${REPOS[1]}")
CHANGES+=("${CHANGES[1]}")
BRANCHES+=("${BRANCHES[1]}")
REMOTES+=("${REMOTES[1]}")
REMOTE_STATUSES+=("${REMOTE_STATUSES[1]}")

for i in $(seq 0 1 $(( ${#REPOS[@]} - 1)) ); do
    column_1="${COLUMN_1[${i}]}"
    repo="${REPOS[${i}]}"
    changes="${CHANGES[${i}]}"
    branch="${BRANCHES[${i}]}"
    remote="${REMOTES[${i}]}"
    status="${REMOTE_STATUSES[${i}]}"

    # number of extra padding characters to add to account for text formatting
    extraPadding=1

    prefix=''
    suffix=''

    # make the header row printed in bold
    if [ "${i}" = "0" ]; then
        prefix=$(echo -e '\e[1m')
        suffix=$(echo -e '\e[0m')
    fi

    printf "\
| ${prefix}%-$(( ${COLUMN_1_STRLEN} + ${extraPadding} ))s${suffix}\
| ${prefix}%-$(( ${MAX_REPO_STR_LEN} + ${extraPadding} ))s${suffix}\
| ${prefix}%-$(( ${CHANGES_STR_LEN} + ${extraPadding} ))s${suffix}\
| ${prefix}%-$(( ${BRANCHES_STR_LEN} + ${extraPadding} ))s${suffix}\
| ${prefix}%-$(( ${REMOTES_STR_LEN} + ${extraPadding} ))s${suffix}\
| ${prefix}%-$(( ${REMOTE_STATUSES_STR_LEN} + ${extraPadding} ))s${suffix}\
|\n" \
    "${column_1}" "${repo}" "${changes}" "${branch}" "${remote}" "${status}"
done
