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
# Script library - Basic Bash utilities

# load additional script function libraries
# "load_script_library.sh" must be on the path
. load_script_library.sh strings

# generate absolute path from relative path
# $1     : relative filename
# return : absolute path
#
# http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
function abspath() {
    if [ -d "${1}" ]; then
        # dir
        (cd "${1}"; pwd)
    elif [ -f "${1}" ]; then
        # file
        if [[ $1 == */* ]]; then
            echo "$(cd "${1%/*}"; pwd)/${1##*/}"
        else
            echo "$(pwd)/$1"
        fi
    fi
}

# Pure bash implementation of `basename`
# $1     : filename/path
# return : file basename
#
# https://stackoverflow.com/a/965072
function file_basename() {
  local filepath

  filepath="${1}"

  if [ -z "${filepath}" ]; then
    >&2 echo "file name/path must be provided as first argument"
    return 1
  fi

  # handle case where they may or may not be a "/" in the path
  if str_contains "${filepath}" "/"; then
    echo "${filepath##*/}"
  else
    echo "${filepath}"
  fi

  return 0
}

# echos the file extension, or the empty string if the file has no extension
# $1     : filename/path
# return : absolute path
#
# https://stackoverflow.com/a/965072
function file_extension() {
  local filepath
  local filename

  filepath="${1}"

  if [ -z "${filepath}" ]; then
    >&2 echo "file name/path must be provided as first argument"
    return 1
  fi

  filename="$(file_basename "${filepath}")"

  # handle case where filename may or may not have an extension
  if str_contains "${filename}" "."; then
    echo "${filename##*.}"
  else
    # no extension
    echo ''
  fi

  return 0
}