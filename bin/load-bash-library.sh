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

# Calculate the bash script library directory
if [ -z "${__TMP_LIB_DIR:-}" ]; then
    __TMP_LIB_DIR="$(dirname "$(dirname "$(realpath.sh "${BASH_SOURCE[0]}")")")/bashlib"
fi

__TMP_RECURSION_DEPTH="${__TMP_RECURSION_DEPTH:-0}"

__TMP_RECURSION_DEPTH=$((__TMP_RECURSION_DEPTH + 1))

if [ "${#}" == "0" ]; then
    # no names provided, source all libraries
    for library in "${__TMP_LIB_DIR}"/script_library_*.sh; do
        # shellcheck source=/dev/null
        . "${library}"
    done
elif [[ "${#}" == "1" && ( "${1}" == "--help" || "${1}" == "-h" ) ]]; then
    >&2 echo "Usage: ${0} [library 1] [library 2] ..."
    >&2 echo "If libraries are specified, only those will be loaded."
    >&2 echo "If no libraries are specified, all supported libraries will be loaded."
    >&2 echo ""
    >&2 echo "Supported script libraries:"
    for library in "${__TMP_LIB_DIR}"/script_library_*.sh; do
        echo "  - $(basename "${library}" | sed -e 's/bashlib_\(.*\).sh/\1/')"
    done
else
    for library_name in "${@}"; do

        # name of sentinel value used to indicate we've loaded the library
        __TMP_LOADED_ENV_VAR_NAME="__LOADED_SCRIPT_LIBRARY_${library_name}"

        # only load the library if we haven't already loaded it,
        # to prevent infinite recursion loops if there's a circular dependency
        if [ -z "${!__TMP_LOADED_ENV_VAR_NAME:-}" ]; then

            # set dynamically generated variable name
            eval export "${__TMP_LOADED_ENV_VAR_NAME}=true"

            # shellcheck source=/dev/null
            . "${__TMP_LIB_DIR}/bashlib_${library_name}.sh"
        fi
    done
fi

__TMP_RECURSION_DEPTH=$((__TMP_RECURSION_DEPTH - 1))

# since scripts are expected to source this script,
# unset variables before we exit to avoid polluting env
if [ "${__TMP_RECURSION_DEPTH}" == "0" ]; then

    unset __TMP_RECURSION_DEPTH
    unset __TMP_LOADED_ENV_VAR_NAME
    unset __TMP_LIB_DIR

    for kv in $(env | grep '__LOADED_SCRIPT_LIBRARY_'); do
        # shellcheck disable=SC2001
        k=$(echo "${kv}" | sed -e "s/\(.*\)=.*/\1/")
        unset "${k}"
    done
fi
