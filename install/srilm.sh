#!/bin/bash
#
# SRILM (most recent version)
# Project Page: http://www.speech.sri.com/projects/srilm/
# Download Page: http://www.speech.sri.com/projects/srilm/download.html
#
# This script was created according to the installation instructions at http://www.speech.sri.com/projects/srilm/docs/INSTALL
#
# Usage via binaries.
#
# Installs to: local directory
#
# Dependencies:
# * g++ 3.4.3+ (via package manager)
# * make (via package manager)
# * gawk (via package manager)
#
# NOTE:
# This script doesn't require admin rights and it's not recommended to execute with admin rights, e.g. via sudo.
#

# basic functions
source installer.sh

# resolve dependencies
## g++
if ! checkPackage g++; then
  installPackages g++
fi
## make
if ! checkPackage make; then
  installPackages make
fi

# SRILM
SRILM=srilm-1.7.1
SRILM_ARCHIVE=${SRILM}.tar.gz
## download instructions
if [ ! -f ${SRILM_ARCHIVE} ]; then
  echo 'SRILM was not found. Please download SRILM manually from its download page http://www.speech.sri.com/projects/srilm/download.html to this directory. Run this script afterwards.'
  exit 2
fi
## extract
if [ ! -d ${SRILM} ]; then
  mkdir ${SRILM}
  cd ${SRILM}
  tar -xf ../${SRILM_ARCHIVE}
  cd ..
  echo 'SRILM extracted.'
fi
## set SRILM variable in Makefile (point at SRILM directory)
DIR=$( getCurrentDir )
MAKEFILE_SRILM=$( echo "SRILM = ${DIR}/${SRILM}" | escape_slashes )
echo "replacing to ${MAKEFILE_SRILM}"
cd ${SRILM}
sed -i "s/^# SRILM =.*/${MAKEFILE_SRILM}/" Makefile
cd ..
## compile
cd ${SRILM}
make && make cleanest
cd ..
echo 'SRILM is ready for usage.'

