#!/bin/bash
#
# Note: This script is not intended to be executed directly.
# It is part of the installation wizard of ULMA.
# Please don't run this script directly, but run the installation wizard instead.
#
# ULMA (unified language model API) supports various tools and toolkits and provides one single API to use any of them.
#
# Authors:
# Sebastian Schlicht (sebastian@jablab.de)
#

# Installs KenLM and its dependencies.
#
# # KenLM 1.7.1
# http://kheafield.com/code/kenlm/
#
# ## Installation target
# './srilm-1.7.1/' which is stored in `$SRILM`
# Binaries will be found in 'bin/<architecture>/'
#
# ## Dependencies
# * Boost 1.36.0+ (libboost-all-dev via apt)
# * g++ (build-essential via apt)
# * zlib (zlib1g-dev via apt)
#
function install_srilm {
  # license agreement
  if ! acceptLicense 'KenLM' 'custom license' 'https://raw.github.com/kpu/kenlm/master/LICENSE'; then
    return 1
  fi
  
  # download
  KENLM_DIR='kenlm'
  KENLM_FILE="$KENLM_DIR"'.tar.gz'
  if [ ! -f $KENLM_FILE ]; then
    wget -O - http://kheafield.com/code/kenlm.tar.gz
    SUCCESS=$?
    
    if [ "$SUCCESS" -ne 0 ]; then
      echo 'Failed to download KenLM!'
      return 2
    fi
    echo 'Download completed.'
  fi
  
  # install dependencies
  requirePackage build-essential
  requirePackage libboost-all-dev
  requirePackage zlib1g-dev
  
  # extract
  tar -xf "$KENLM_FILE"
  if [ $? -ne 0 ]; then
    echo 'Failed to extract KenLM!'
    return 4
  fi
  echo 'SRILM was extracted successfully.'
  
  # install
  echo 'The wizard will build and install KenLM now.'
  cd "$KENLM_DIR"
  ./bjam -j4
  SUCCESS=$?
  cd ..
  
  if [ "$SUCCESS" -eq 0 ]; then
    echo 'KenLM was installed successfully.'
  fi
  return $SUCCESS
}

