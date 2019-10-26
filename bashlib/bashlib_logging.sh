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
# Script library - logging

# documentation:
#     - https://misc.flogisoft.com/bash/tip_colors_and_formatting
#
# "\e[" starts escape sequence
# "m" ends escape sequence
# multiple codes can be given in the same sequence, separated by a semicolon (";")
# codes:
#    00 - reset all special configuration
#    01 - bold/bright
#    31 - red
#    32 - green
#    34 - blue

function __log_message() {
  local bold=$'\e[01m'
  local white=$'\e[39m'
  local green=$'\e[32m'
  local reset=$'\e[00m'
  local open_bracket="${reset}${bold}${white}[${reset}"
  local close_bracket="${reset}${bold}${white}]${reset}"

  # +%Y-%m-%d %H:%M:%S.%3N
  local -r now="$(date '+%H:%M:%S.%3N')"

  printf '%s%s%s%s%s%s%s%-10s%s%s %s\n' \
    "${open_bracket}" "${green}" "${now}" "${reset}" "${close_bracket}" \
    "${open_bracket}" "${bold}" "${1}" "${reset}" "${close_bracket}" \
    "${2}" || true
}

function log.debug() {
  __log_message $'\e[90mDEBUG' "${*}"
}

function log.info() {
  __log_message $'\e[34mINFO' "${*}"
}

function log.warn() {
  __log_message $'\e[33mWARN' "${*}"
}

function log.error() {
  __log_message $'\e[35mERROR' "${*}"
}

function log.fatal() {
  __log_message $'\e[31mFATAL' "${*}"
}