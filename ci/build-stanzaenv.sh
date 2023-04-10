#!/bin/bash
set -Eeuxo pipefail
PS4='>>> '
TOP="${PWD}"

# This script is designed to be run from a Concourse Task with the following env vars

USAGE="STANZA_CONFIG=/path $0"

# Required env var inputs
echo "     STANZA_CONFIG:" "${STANZA_CONFIG:?Usage: ${USAGE}}"          # directory where .stanza config file will be stored, as in normal stanza behavior

# Defaulted env var inputs - can override if necessary
echo "              REPODIR:" "${REPODIR:=lbstanza}"
echo "      CONAN_USER_HOME:" "${CONAN_USER_HOME:=$(readlink -f ${REPODIR})}"
echo "       CREATE_ARCHIVE:" "${CREATE_ARCHIVE:=false}"
echo "       CREATE_PACKAGE:" "${CREATE_PACKAGE:=false}"
echo "STANZA_BUILD_PLATFORM:" "${STANZA_BUILD_PLATFORM:=$(uname -s)}"  # linux|macos|windows
echo "                  VER:" "${VER:=$(git -C ${REPODIR} describe --tags --abbrev=0)}"
export CONAN_USER_HOME

# special case - if STANZA_CONFIG starts with "./", then replace it with the full path
[[ ${STANZA_CONFIG::2} == "./" ]] && STANZA_CONFIG=${PWD}/${STANZA_CONFIG:2}

# Calculated env vars
STANZADIR=$(grep ^install-dir $STANZA_CONFIG/.stanza | cut -f2 -d\")

PLATFORM_DESC="unknown"
case "$STANZA_BUILD_PLATFORM" in
    Linux* | linux* | ubuntu*)
        STANZA_BUILD_PLATFORM=linux
        STANZAENV_BUILD_PLATFORM=linux
        STANZA_PLATFORMCHAR="l"
        PLATFORM_DESC="$(grep ^ID= /etc/os-release | cut -f2 -d=)-$(grep ^VERSION_CODENAME= /etc/os-release | cut -f2 -d=)"
    ;;
    Darwin | mac* | os-x)
        STANZA_BUILD_PLATFORM=os-x
        STANZAENV_BUILD_PLATFORM=osx
        STANZA_PLATFORMCHAR=""
        PLATFORM_DESC="macos-unknown"
        case "$(sw_vers -productVersion)" in
            13.*)
                PLATFORM_DESC="macos-ventura"
            ;;
            12.*)
                PLATFORM_DESC="macos-monterey"
            ;;
            11.*)
                PLATFORM_DESC="macos-bigsur"
            ;;
            10.15.*)
                PLATFORM_DESC="macos-catalina"
            ;;
            10.14.*)
                PLATFORM_DESC="macos-mojave"
            ;;
            10.13.*)
                PLATFORM_DESC="macos-highsierra"
            ;;
            10.12.*)
                PLATFORM_DESC="macos-sierra"
            ;;
        esac
    ;;
    MINGW* | win*)
        STANZA_BUILD_PLATFORM=windows
        STANZAENV_BUILD_PLATFORM=windows
        STANZA_PLATFORMCHAR="w"
        PLATFORM_DESC="windows-unknown"
        case "$(uname -s)" in
            MINGW64*)
                PLATFORM_DESC="windows-mingw64"
            ;;
        esac
    ;;
    *)
        printf "\n\n*** ERROR: unknown build platform \"${STANZA_BUILD_PLATFORM}\"\n\n\n" && exit -2
    ;;
esac


cd "${REPODIR}"
echo "Building stanzaenv version ${VER} in ${PWD}"

stanza build stanzaenv-${STANZAENV_BUILD_PLATFORM} -verbose

ls -l build/stanzaenv-${STANZAENV_BUILD_PLATFORM}


if [ "$CREATE_PACKAGE" == "true" ] ; then
  #VERU=${VER//./_}  # convert dots to underscores
  STANZA_EXT=""
  [[ "${STANZA_PLATFORMCHAR}" == "w" ]] && STANZA_EXT=".exe"

  FILES="docs \
         bin \
         include \
         ${STANZA_PLATFORMCHAR}pkgs \
         ${STANZA_PLATFORMCHAR}stanza${STANZA_EXT} \
         core \
         compiler \
         examples \
         runtime \
         stanza.proj \
         License.txt \
         ChangeLog.txt"

  mkdir -p ziptmp/build
  cp -r ${FILES} ziptmp/

  cd ziptmp

  # rename "lstanza" to "stanza" and "wstanza.exe" to "stanza.exe"
  [[ "${STANZA_PLATFORMCHAR}stanzaenv" != "stanzaenv" ]] \
      && mv ${STANZA_PLATFORMCHAR}stanzaenv${STANZA_EXT} stanzaenv${STANZA_EXT} \
      && mv ${STANZA_PLATFORMCHAR}pkgs pkgs

  #zip -r ../${STANZA_PLATFORMCHAR}stanza_${VERU}.zip *
  zip -r ../stanza-${PLATFORM_DESC}_${VER}.zip *

fi

# if [ "$CREATE_ARCHIVE" == "true" ] ; then
#   zip -r -9 -q stanza-build-${PLATFORM}-${VER}.zip \
#      .conan \
#      .stanza \
#      CMakeUserPresets.json \
#      build
# fi
