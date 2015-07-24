#!/bin/bash
# ULMA.KenLM
#
# This script is part of the [ULMA API](https://github.com/sebschlicht/phd-thesis/blob/lm/toolkit-benchmark/ulma/ulma.md).
# It is a wrapper for the KenLM toolkit, to provide an endpoint for ULMA users.
#
# Authors: Sebastian Schlicht
#

KENLM_BIN=kenlm/bin

# start argument parsing with toolkit set
if [ -z $ULMA_TOOLKIT ]; then
  ULMA_TOOLKIT=kenlm
  source ulma.sh
fi

# Creates a language model using the current application parameter state.
#
# # Resources:
# * [KenLM documentation](http://kheafield.com/code/kenlm/)
# ** [Estimation](http://kheafield.com/code/kenlm/estimation/)
function lmplz {
  # WARNING: KenLM interpretes blank lines in corpus!
  OPT_LMPLZ='-o '"$ORDER"' --text '"$INPUT_FILE"
  
  # smoothing method
  case $SMOOTHING_METHOD in
    MKN)
      # is the only smoothing method available
      ;;
    # no / unknown smoothing method -> fallback to MLE
    *)
      echo '[ERROR] KenLM only supports modified Kneser-Ney smoothing!'
      exit 99
      ;;
  esac
  
  # don't interploate unigrams (default in SRILM)
  OPT_LMPLZ="$OPT_LMPLZ"' --interpolate_unigrams 0'
  
  OPT_LMPLZ="$OPT_LMPLZ"' --arpa '"$OUTPUT_FILE"
  
  $KENLM_BIN/lmplz $OPT_LMPLZ
}

