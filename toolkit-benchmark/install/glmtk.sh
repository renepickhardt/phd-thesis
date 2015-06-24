#!/bin/bash
#
# GLMTK / Generalized language modeling toolkit (most recent version)
# Project Page: https://github.com/renepickhardt/generalized-language-modeling-toolkit
#
# Usage via TODO.
#
# Will be located in: local directory
#
# Dependencies:
# * git
# * Maven
#

# basic functions
source installer.sh

# resolve dependencies
## git
if ! getCommandPath git; then
  installPackages git
fi
## maven
if ! getCommandPath maven; then
  installPackages maven
fi

# GLMTK
GLMTK=generalized-language-modeling-toolkit
## download
if [ ! -d ${GLMTK} ]; then
  git clone https://github.com/renepickhardt/generalized-language-modeling-toolkit.git
fi
## install
cd ${GLMTK}
chmod u+x mvn.sh
cp config.sample.txt config.txt

# TODO give some configuration options

cd ..
echo 'GLMTK is ready for usage.'

