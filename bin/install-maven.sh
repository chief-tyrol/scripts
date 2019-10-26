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

# manually installs a specific version of Maven
# https://maven.apache.org/install.html

set -o errexit
set -o nounset

DEAULT_VERSION='3.6.2'

if [ "${EUID:-1}" != '0' ]; then
  exec sudo -p "\`$(basename "${BASH_SOURCE[0]}")\` requires %U access, please enter password: " PATH="${PATH}" -s "${BASH_SOURCE[0]}" "${@}"
fi

function usage() {
  local -r name="$(basename "${BASH_SOURCE[0]}")"

  # abuse command substitution to assign heredoc to a variable
  docstring=$(cat <<-EOF
Usage: ${name} [version]

Installs the specified version of Maven, or Maven ${DEAULT_VERSION} if no version is specified
EOF
)
  # use `&& false` to ensure return code is `1`
  printf '%s\n' "${docstring}" >&2 && false
}

function delete_if_exists() {
  file="${1}"

  if [ -e "${file}" ]; then
    echo -n "[WARNING] ${file} already exists, deleting... "
    rm -rf "${file}"
    echo "deleted successfully"
  fi
}

# parse input
case "${#}" in
  0) VERSION="${DEAULT_VERSION}" ;;
  1) VERSION="${1}"              ;;
  *) usage                       ;;
esac

MIRROR=http://www.apache.org/dist

DOWNLOAD_FILE="/tmp/maven.tar.gz"

MAVEN_INSTALL_FOLDER_PARENT="/opt/maven"
MAVEN_INSTALL_FOLDER="${MAVEN_INSTALL_FOLDER_PARENT}/apache-maven-${VERSION}"

MVN_EXEC='/usr/bin/mvn'
MVNDEBUG_EXEC='/usr/bin/mvnDebug'

MVN_BINARY="${MAVEN_INSTALL_FOLDER}/bin/mvn"
MVNDEBUG_BINARY="${MAVEN_INSTALL_FOLDER}/bin/mvnDebug"

delete_if_exists "${DOWNLOAD_FILE}"

curl -sS --fail "${MIRROR}/maven/maven-3/${VERSION}/binaries/apache-maven-${VERSION}-bin.tar.gz" -o "${DOWNLOAD_FILE}"

tar -xf "${DOWNLOAD_FILE}" --directory /tmp
rm -rf "${DOWNLOAD_FILE}"

mkdir -p "${MAVEN_INSTALL_FOLDER_PARENT}"
delete_if_exists "${MAVEN_INSTALL_FOLDER}"

mv -f "/tmp/apache-maven-${VERSION}" "${MAVEN_INSTALL_FOLDER}"

chmod a+x "${MVN_BINARY}"
chmod a+x "${MVNDEBUG_BINARY}"

echo "Maven ${VERSION} successfully installed into ${MAVEN_INSTALL_FOLDER}"

#
# Successfully moved into install folder, now need to create symlinks so it's available on the path
#
if command -v update-alternatives > /dev/null 2>&1; then
  echo "update-alternatives available, using it to create symlinks in $(dirname "${MVN_EXEC}")"

  update-alternatives --remove-all mvn

  update-alternatives --install "${MVN_EXEC}"      mvn      "${MVN_BINARY}"      10000 \
                      --slave   "${MVNDEBUG_EXEC}" mvnDebug "${MVNDEBUG_BINARY}"

else

  echo "update-alternatives not available, manually creating symlinks in $(dirname "${MVN_EXEC}")"

  delete_if_exists "${MVN_EXEC}"
  delete_if_exists "${MVNDEBUG_EXEC}"

  ln -s "${MVN_BINARY}"      "${MVN_EXEC}"
  ln -s "${MVNDEBUG_BINARY}" "${MVNDEBUG_EXEC}"
fi

# errexit means we only get here if everything was successful
echo "Installation of Maven ${VERSION} complete:"
mvn --version
