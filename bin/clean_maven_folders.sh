#!/usr/bin/env bash
#
# Cleans build artifacts from all maven projects in a folder
#

if [ "${#}" == "0" ]; then
    ROOT="`pwd`"
elif [ "${#}" == "1" ]; then
    ROOT="${1}"
else
    echo "Usage: $0 [folder]"
    echo "Runs \`mvn clean\` in subfolders of [folder], or the current working directory if [folder] is not provided"
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

echo "[INFO] Cleaning projects in \"${ROOT}\""

for folder in `ls -1 "${ROOT}"`; do

    # make sure we start in the correct directory
    cd "${ROOT}"

    if [ ! -d "${folder}" ]; then
        # not a folder, ignore
        continue
    fi

    cd "${folder}"

    if [ ! -f 'pom.xml' ]; then
        # not a maven project, ignore
        continue
    fi

    echo -n "[INFO]   Cleaning ${ROOT}/${folder}..."

    # run the actual maven clean
    mvn clean >/dev/null 2>&1

    # after running mvn clean, also clear out any dependency reduced poms
    find . -name "dependency-reduced-pom.xml" -delete

    echo " done!"
done

echo "[INFO] Cleaned projects in \"${ROOT}\""
