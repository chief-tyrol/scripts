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
#
# Cleans build artifacts from all maven projects in a folder

if [ "${#}" == "0" ]; then
    ROOT="`pwd`"
elif [ "${#}" == "1" ]; then
    ROOT="${1}"
else
    echo "Usage: $0 [folder]"
    echo "Runs \`mvn clean\` in subfolders of [folder], or the current working directory if [folder] is not provided"
    exit 1
fi

# load additional script function libraries
# "load_script_library.sh" must be on the path
. load_script_library.sh basic

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
