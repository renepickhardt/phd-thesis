#!/bin/bash
#
# DALM / Double-Array language model (most recent version)
# Project Page: https://github.com/jnory/DALM
#
# Usage via binaries or C++.
#
# Installs to (default): /opt/dalm
#
# Dependencies:
# * git
#

# basic functions
source installer.sh

# resolve dependencies
## git
if ! checkPackage git; then
  installPackages git
fi

# DALM
DALM=DALM
DALM_DEFAULT_TARGET=/opt/dalm
## download
if [ ! -d ${DALM} ]; then
  git clone https://github.com/jnory/DALM.git
fi
## install
cd ${DALM}
read -p "Choose an installation directory for DALM [${DALM_DEFAULT_TARGET}]: " DALM_TARGET
DALM_TARGET=${DALM_TARGET:-$DALM_DEFAULT_TARGET}
./waf configure build install --prefix=${DALM_TARGET}
RES=$?
if [ ! $RES -eq 0 ]; then
  echo 'Failed to install DALM!'
  exit $RES
fi
cd ..

echo 'DALM is ready for usage.'

