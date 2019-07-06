#!/bin/bash

DELEGATE="update_gitrepos.sh"

if [ "${#}" == "0" ]; then
    ROOT="$(pwd)"
elif [ "${#}" == "1" ]; then
    ROOT="${1}"
else
    echo "Usage: ${0} [folder]"
    echo "Update all git projects in subfolders of subfolders [folder]. If [folder] is not provided, it defaults to the current working directory"
    echo "e.g, if your git folder layout looked like:"
    echo ""
    echo "  \${HOME}"
    echo "      \-git"
    echo "        \-organization"
    echo "          \-repo1"
    echo "          \-repo2"
    echo "        \-organization2"
    echo "          \-repo3"
    echo "          \-repo4"
    echo ""
    echo "then you could run ${0} \"\${HOME}/git\" to update all four repos"
    echo ""
    echo "Implementation note: internally, this command delegates to ${DELEGATE}"
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

for folder in `ls -1 "${ROOT}"`; do

    # make sure we start in the correct directory
    cd "${ROOT}"

    if [ ! -d "$folder" ]; then
        # skip non-directories
        continue
    fi

    cd "$folder"

    "${DELEGATE}" "${ROOT}/${folder}"
done
