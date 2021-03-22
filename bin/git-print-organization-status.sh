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
set -o pipefail

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

function seperator() {
    echo "----------------------------------------"
}

# load additional functions (`load-bash-library.sh` must be on the PATH)
. load-bash-library.sh files git math strings

FOLDER="$(abspath "${FOLDER}")"

if [ ! -d "${FOLDER}" ]; then
    echo "[ERROR] \"${FOLDER}\" is not a directory"
    exit 1
fi

placeholder=''
COLUMN_1=('Organization' "${placeholder}")
COLUMN_2=('Repository' "${placeholder}")
COLUMN_3=('Uncommitted Changes' "${placeholder}")
COLUMN_4=('Branch' "${placeholder}")
COLUMN_5=('Tracking' "${placeholder}")
COLUMN_6=('Commit Delta With Remote' "${placeholder}")

# must be manually modified if column count changes
COLUMNS_COUNT=6

# initialize variables
COLUMN_1_STRLEN='0'
COLUMN_2_STRLEN='0'
COLUMN_3_STRLEN='0'
COLUMN_4_STRLEN='0'
COLUMN_5_STRLEN='0'
COLUMN_6_STRLEN='0'

for folder in "${FOLDER}"/*; do

    if [ ! -d "${folder}" ]; then
        # skip non-folders
        continue
    fi

    cd "${folder}" || exit 1

    if ! is_git_repo; then
        # skip non-repos
        continue
    fi

    COLUMN_1+=( "$(basename "${FOLDER}")" )
    COLUMN_2+=( "$(basename "${folder}")" )
    COLUMN_3+=( "$(if local_git_changes_exist; then echo "exist"; else echo "none"; fi )" )
    COLUMN_4+=( "$(parse_git_branch_name)" )

    remote="$(parse_git_remote_branch_name)"

    if [ -z "${remote}" ]; then
        COLUMN_5+=('none')
        COLUMN_6+=('N/A')
    else
        COLUMN_5+=("${remote}")
        COLUMN_6+=("$(compare_local_git_branch_with_remote)")
    fi
done

# calculate the longest line in each column
for row in $(seq 0 1 $(( ${#COLUMN_1[@]} - 1)) ); do

    # column variables are one indexed
    for column in $(seq 1 1 "${COLUMNS_COUNT}" ); do

        # dynamically calculate variable names
        lengthName="COLUMN_${column}_STRLEN"
        specificColumnArrayName="COLUMN_${column}[${row}]"
        thisLength=$(strlen "${!specificColumnArrayName}")

        # technically don't need eval + export, but IDE yells if it's not done this way
        eval export "${lengthName}=$(max "${!lengthName}" "${thisLength}")"
    done
done

# Now that we know the size of each column, add the sub-header separators.
# Column variables are one indexed
for column in $(seq 1 1 "${COLUMNS_COUNT}" ); do

    # dynamically calculate variable names
    lengthName="COLUMN_${column}_STRLEN"
    columnArrayName="COLUMN_${column}"
    specificColumnArrayName="${columnArrayName}[1]"
    text=$(repeat_string '-' "${!lengthName}")

    eval "${specificColumnArrayName}=${text}"
    eval "${columnArrayName}+=(\"${text}\")"
done

# actually print out the data
for row in $(seq 0 1 $(( ${#COLUMN_1[@]} - 1)) ); do
    # number of extra padding characters to add to account for text formatting
    padding=1

    prefix=''
    suffix=''

    # print the header row in bold
    if [ "${row}" == "0" ]; then
        prefix=$(echo -e '\e[1m')
        suffix=$(echo -e '\e[0m')
    fi

    printf "\
| ${prefix}%-$(( COLUMN_1_STRLEN + padding ))s${suffix}\
| ${prefix}%-$(( COLUMN_2_STRLEN + padding ))s${suffix}\
| ${prefix}%-$(( COLUMN_3_STRLEN + padding ))s${suffix}\
| ${prefix}%-$(( COLUMN_4_STRLEN + padding ))s${suffix}\
| ${prefix}%-$(( COLUMN_5_STRLEN + padding ))s${suffix}\
| ${prefix}%-$(( COLUMN_6_STRLEN + padding ))s${suffix}\
|\n" \
    "${COLUMN_1[${row}]}" \
    "${COLUMN_2[${row}]}" \
    "${COLUMN_3[${row}]}" \
    "${COLUMN_4[${row}]}" \
    "${COLUMN_5[${row}]}" \
    "${COLUMN_6[${row}]}"
done
