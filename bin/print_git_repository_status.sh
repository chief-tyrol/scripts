#!/bin/bash
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