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
# Cleans build artifacts from all maven projects in a folder

set -o errexit
set -o nounset

if [ "${#}" == "0" ]; then
    ROOT="$(pwd)"
elif [ "${#}" == "1" ]; then
    ROOT="${1}"
else
    >&2 echo "Usage: $0 [folder]"
    >&2 echo "Runs \`mvn clean\` in subfolders of [folder], or the current working directory if [folder] is not provided"
    exit 1
fi

# load additional script function libraries
# "load_script_library.sh" must be on the path
. load_script_library.sh files

ROOT="$(abspath "${ROOT}")"

if [ ! -d "${ROOT}" ]; then
    >&2 echo "[ERROR] \"${ROOT}\" is not a directory"
    exit 1
fi

_OTHER_MAVEN_FILES=(
    pom.xml.bak
    pom.xml.tag
    pom.xml.releaseBackup
    pom.xml.versionsBackup
    pom.xml.next
    dependency-reduced-pom.xml
    release.properties
)

ORIGINAL_DIR="$(pwd)"
echo "[INFO] Cleaning projects in \"${ROOT}\""

for folder in "${ROOT}"/*; do

    if [ ! -d "${folder}" ]; then
        # not a folder, ignore
        continue
    fi

    cd "${folder}" || exit 1

    if [ ! -f 'pom.xml' ]; then
        # not a maven project, ignore
        continue
    fi

    echo -n "[INFO]   Cleaning ${folder}..."

    # run the actual maven clean
    mvn clean >/dev/null 2>&1

    # clear out any other cruft maven files that may have accumulated
    for file in "${_OTHER_MAVEN_FILES[@]}"; do
        find . -name "${file}" -delete
    done

    echo " done!"
done

cd "${ORIGINAL_DIR}" || exit 1
echo "[INFO] Cleaned projects in \"${ROOT}\""
