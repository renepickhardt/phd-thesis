#!/bin/bash
#
# NLTK (most recent version)
# Project Page: https://github.com/nltk/nltk , http://www.nltk.org/
#
# Usage via Python module.
#
# Installs as: Python library
# e.g. to /usr/local/lib/python2.7/dist-packages/nltk-3.0.3-py2.7.egg
#
# Dependencies:
# * Python 2.6-2.7 / 3.2+ (via package manager)
# * [git] (via package manager)
# OR install via pip instead of cloning the git repository
#

# basic functions
source installer.sh

# resolve dependencies
## Python 2
if ! checkPackage python; then
  installPackages python
fi
## Python 2 setuptools
if ! checkPackage python-setuptools; then
  installPackages python-setuptools
fi
## git
if ! checkPackage git; then
  installPackages git
fi

# NLTK
NLTK=nltk
## download
if [ ! -d ${NLTK} ]; then
  git clone https://github.com/nltk/nltk.git
fi
## install
if [ -d ${NLTK} ]; then
  cd ${NLTK}
  echo 'Installing NLTK via setup.py...'
  python setup.py install
  cd ..
else
  echo 'Failed to retrieve NLTK sources via git clone!'
  exit 1
fi
echo 'NLTK is ready for usage.'

