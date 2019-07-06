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

# Script which can be run on a folder to convert all jpg images in the folder
# to 90% quality, and back up each original file named "foo.jpg" to "large foo.jpg"
#
# Meant for use with DSLR cameras that produce 15MB+ images, when you don't need to
# keep images that large
#
set -e

function now() {
    date --rfc-3339=second
}

IFS=$'\n'
folder="${1:-}"
iteration=0

if [ -z "$(which convert)" ]; then
    echo "[`now`][FATAL] Unable to find imagemagick on the path"
    echo "[`now`][FATAL] Please run 'sudo apt install -y imagemagick' first"
    exit 1
fi

if [ -z "${folder}" ]; then
    echo "[`now`][FATAL] Must specify folder"
    exit 1
fi

echo "[`now`][INFO] Running on folder \"${folder}\""

for file in $(ls -1 "${folder}"); do
    let iteration=iteration+1

    if [[ "${file}" == large* ]]; then
        echo "[`now`][WARN] Ignoring ${file}"
        continue;
    fi

    extension=$(echo "${file}" | awk -F '\\.' '{print $2}')

    if [ "${extension}" != 'JPG' ] && [ "${extension}" != 'jpg' ]; then
        echo "[`now`][WARN] Ignoring ${file}"
        continue;
    fi

    new_name=$(echo "${file}" | awk -F '\\.' '{print "large "$1"."$2}')

    if [ $((iteration % 8)) == 0 ]; then
        wait
    fi

    echo "[`now`][INFO] Currently on iteration #${iteration}, processing ${file}"

    mv "${folder}/${file}" "${folder}/${new_name}"
    convert "${folder}/${new_name}" -quality 90 "${folder}/${file}" &
done
