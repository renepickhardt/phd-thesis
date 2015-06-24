#!/bin/bash
#
# KenLM (most recent version)
# Project Page: http://kheafield.com/code/kenlm/
#
# Usage via (compilable) binaries and Python module.
# Can't create ARPA files.
#
# Installs to: ./kenlm
#
# Dependencies:
# * g++ (via package manager)
# * [Boost](http://www.boost.org/doc/libs/1_58_0/more/getting_started/unix-variants.html) 1.36.0+ (installs 1.58.0)
#

# basic functions
source installer.sh

# resolve dependencies
## g++
if ! checkPackage g++; then
  installPackages g++
fi
## Boost
getBoost

# KenLM
KENLM=kenlm
KENLM_ARCHIVE=${KENLM}.tar.gz
## download
if [ ! -f ${KENLM_ARCHIVE} ]; then
  echo 'Downloading KenLM...'
  wget kheafield.com/code/kenlm.tar.gz
fi
if [ ! -d ${KENLM} ]; then
  tar -xf ${KENLM_ARCHIVE}
fi
if [ ! -d ${KENLM} ]; then
  echo 'Failed to extract KenLM!'
  exit 1
fi
## link Boost
if [ ! -h ${KENLM}/boost ]; then
  cd ${KENLM}
  ln -s ../boost_1_58_0/boost boost
  cd ..
  echo 'KenLM was configured to use Boost.'
fi
## compile
if [ ! -d ${KENLM}/bin ]; then
  cd ${KENLM}
  ./compile_query_only.sh
  #./bjam -j4
  cd ..
fi
echo 'KenLM is ready for usage.'

