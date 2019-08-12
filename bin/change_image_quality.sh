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

# Script which can be run on a FOLDER to convert all jpg images in the FOLDER
# to 90% quality, and back up each original file named "foo.jpg" to "large foo.jpg"
#
# Meant for use with DSLR cameras that produce 15MB+ images, when you don't need to
# keep images that large

set -e

# precondition to running the script
if ! command -v convert > /dev/null 2>&1; then
  >&2 echo "[FATAL] Unable to find imagemagick on the path"
  >&2 echo "[FATAL] Please run 'sudo apt install -y imagemagick' first"
  exit 1
fi

FOLDER=''

if [ "${#}" == "0" ]; then
    FOLDER="$(pwd)"
elif [ "${#}" == "1" ]; then
    FOLDER="${1}"
else
    >&2 echo "Usage: $0 [folder]"
    >&2 echo "Changes the quality of jpg images in [folder] to 90, or the current working directory if [folder] is not provided"
    exit 1
fi

# load additional script function libraries
# "load_script_library.sh" must be on the path
. load_script_library.sh basic

# get the full, real path
FOLDER="$(abspath "$(realpath.sh "${FOLDER}")" )"

echo "[INFO] Running on FOLDER \"${FOLDER}\""

ITERATION=0
FILE_COUNT="$(find "${FOLDER}" -maxdepth 1 ! -name "$(basename "${FOLDER}" )" | wc -l)"

for full_file in "${FOLDER}"/*; do
  ITERATION=$(( ITERATION + 1 ))

  LOG_PREFIX="[${ITERATION}/${FILE_COUNT}]"

  file="$(basename "${full_file}")"

  if [[ "${file}" == large* ]]; then
      echo "[WARN]${LOG_PREFIX} Ignoring ${file}"
      continue;
  fi

  extension=$(echo "${file}" | awk -F '\\.' '{print $2}')

  if [ "${extension}" != 'JPG' ] && [ "${extension}" != 'jpg' ]; then
      echo "[WARN]${LOG_PREFIX} Ignoring ${file}"
      continue;
  fi

  new_name=$(echo "${file}" | awk -F '\\.' '{print "large "$1"."$2}')

  if [ $(( ITERATION % 8 )) == 0 ]; then
      wait
  fi

  echo "[INFO]${LOG_PREFIX} Processing ${file}"

  mv "${FOLDER}/${file}" "${FOLDER}/${new_name}"
  convert "${FOLDER}/${new_name}" -quality 90 "${FOLDER}/${file}" &

done
