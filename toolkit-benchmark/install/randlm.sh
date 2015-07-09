#!/bin/bash
#
# RandLM 0.2.5
# Project Page: http://sourceforge.net/projects/randlm/
# License: GNU GPLv2
#
# Usage via TODO
#
# Installs to: TODO
#
# Dependencies:
# * [Boost](http://www.boost.org/doc/libs/1_58_0/more/getting_started/unix-variants.html) 1.36.0+ (installs 1.58.0)
# * Google Sparse Hash
#

# basic functions
source installer.sh

# resolve dependencies
## Boost
getBoost

# RandLM
RANDLM=randlm-0.2.5
RANDLM_ARCHIVE=${RANDLM}.tar.gz
## download
if [ ! -f ${RANDLM_ARCHIVE} ]; then
  echo 'Downloading RandLM...'
  wget http://netcologne.dl.sourceforge.net/project/randlm/randlm-0.2.5.tar.gz
fi
if [ ! -d ${RANDLM} ]; then
  tar -xf ${RANDLM_ARCHIVE}
fi
if [ ! -d ${RANDLM} ]; then
  echo 'Failed to extract RandLM!'
  exit 1
fi
## link Boost
if [ ! -h ${RANDLM}/boost ]; then
  cd ${RANDLM}
  ln -s ../boost_1_58_0/boost boost
  cd ..
  echo 'RandLM was configured to use Boost.'
fi
## compile
if [ ! -d ${RANDLM}/bin ]; then
  cd ${RANDLM}
  ./autogen.sh
  ./configure
  make
  make install
  cd ..
fi
echo 'RandLM is ready for usage.'

