#!/usr/bin/env bash

CCPNMR_TOP_DIR="$(cd "$(dirname "$0")/.." || exit; pwd)"
export CCPNMR_TOP_DIR
export VERSION_PATH=ccpnmr2.5
export CONDA="${CCPNMR_TOP_DIR}"/miniconda
export PYTHONPATH="${CCPNMR_TOP_DIR}/${VERSION_PATH}/python"
export FONTCONFIG_FILE="${CONDA}"/etc/fonts/fonts.conf
export FONTCONFIG_PATH="${CONDA}"/etc/fonts

UNAME="$(uname -s)"
if [[ ${UNAME} == *"Dar"* ]]; then
  export DYLD_FALLBACK_LIBRARY_PATH=${CCPNMR_TOP_DIR}/${VERSION_PATH}/c/libs:
  export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ImageIO.framework/Versions/A/Resources:
  export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}${CONDA}/lib:
  export DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH}${HOME}/lib:/usr/local/lib:/usr/lib:
fi
