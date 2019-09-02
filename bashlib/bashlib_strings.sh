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
# Script library - string utilities

function strlen() {
  echo "${#1}"
}

function repeat_string() {
    str="${1}"
    count="${2}"
    printf '%*s' "${count}" | sed "s/ /${str}/g"
}

# Checks if a string contains another.
#
# $1     : string being checked
# $2     : substring to check for
# return : status code 0 if $1 contains $2, status code 1 otherwise
#
# Examples:
#   str_contains "foo" "o"   # returns 0
#   str_contains "foo" "foo" # returns 0
#   str_contains "foo" "a"   # returns 1
#   str_contains "foo" "bar" # returns 1
#
# https://stackoverflow.com/a/229606
function str_contains() {

  if [[ "${1}" == *"${2}"* ]]; then
    return 0
  fi

  return 1
}