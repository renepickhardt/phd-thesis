#!/bin/bash
#
# OpenGRM (NGram) 1.2.1
# Project Page: http://opengrm.org/
#
# Usage via (compilable) binaries.
# Supports
# * unsmoothed
# * katz (default)
# * kneser_ney
# * presmoothed
# * witten_bell
# smoothing and can export language models to ARPA format.
#
# Installs to: /usr/local
#
# Dependencies:
# * OpenFst 1.4.0+ (installs 1.4.1)
# * g++ 4.6+ (via package manager)
# * make (via package manager)
#
# Commands:
# corpus to FST symbol table: ngramsymbols <input.txt >output.syms
# FST symbol table to FAR (binary): farcompilestrings -symbols=input.syms -keep_symbols=1 input.txt >output.far
# count: ngramcount -order=n input.far >output.fst
# estimate: ngrammake --method=kneser_ney input.fst >output.mod
#
# or
# src/bin/ngram.sh --itype=text_sents --otype=lm --ifile input.txt --ofile output.mod --order=n --smooth_method=kneser_ney
#
# export ARPA: ngramprint --ARPA input.mod >output.ARPA
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
## OpenFst
OPENFST=openfst-1.4.1
OPENFST_ARCHIVE=${OPENFST}.tar.gz
### download
if [ ! -f ${OPENFST_ARCHIVE} ]; then
  echo 'Downloading OpenFst...'
  wget http://www.openfst.org/twiki/pub/FST/FstDownload/openfst-1.4.1.tar.gz
fi
### extract
if [ ! -d ${OPENFST} ]; then
  tar -xf ${OPENFST_ARCHIVE}
  cd ${OPENFST}
  ./configure --enable-far --enable-static=no
  make
  make install
  cd ..
  echo 'OpenFst is ready for usage.'
fi

# OpenGRM
OPENGRM=opengrm-ngram-1.2.1
OPENGRM_ARCHIVE=${OPENGRM}.tar.gz
## download
if [ ! -f ${OPENGRM_ARCHIVE} ]; then
  echo 'Downloading OpenGRM...'
  wget http://openfst.cs.nyu.edu/twiki/pub/GRM/NGramDownload/opengrm-ngram-1.2.1.tar.gz
fi
## extract
if [ ! -d ${OPENGRM} ]; then
  tar -xf ${OPENGRM_ARCHIVE}
  echo 'OpenGRM extracted.'
fi
## compile
cd ${OPENGRM}
./configure --enable-static=no
make
make install
cd ..
echo 'OpenGRM is ready for usage.'

