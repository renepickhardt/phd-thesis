#!/bin/bash
# ULMA.SRILM
#
# This script is part of the [ULMA API](https://github.com/sebschlicht/phd-thesis/blob/lm/toolkit-benchmark/ulma/ulma.md).
# It is a wrapper for the SRILM toolkit, to provide an endpoint for ULMA users.
#
# Authors: Sebastian Schlicht
#

SRILM_BIN=srilm-1.7.1/bin/*

# start argument parsing with toolkit set
if [ -z $ULMA_TOOLKIT ]; then
  ULMA_TOOLKIT=srilm
  source ulma.sh
fi

# Creates a language model using the current application parameter state.
#
# # Resources:
# * [SRILM documentation](http://www.speech.sri.com/projects/srilm/manpages/)
# ** [FAQ](http://www.speech.sri.com/projects/srilm/manpages/srilm-faq.7.html)
# ** [man ngram-count](http://www.speech.sri.com/projects/srilm/manpages/ngram-count.1.html)
function lmplz {
  OPT_NGRAM_COUNT='-text '"$INPUT_FILE"' -order '"$ORDER"
  
  # start-/end-of-sentence tags
  if ! $SOS; then
    OPT_NGRAM_COUNT="$OPT_NGRAM_COUNT"' -no-sos'
  fi
  if ! $EOS; then
    OPT_NGRAM_COUNT="$OPT_NGRAM_COUNT"' -no-eos'
  fi
  OPT_NGRAM_COUNT="$OPT_NGRAM_COUNT"' -lm '"$OUTPUT_FILE"
  
  # smoothing method
  case $SMOOTHING_METHOD in
    KN)
      # TODO
      OPT_NGRAM_COUNT="$OPT_NGRAM_COUNT"' -ukndiscount'
      ;;
    MKN)
      if [ "$CDISCOUNT" = "0" ]; then
        # let SRILM calculate discount values
        OPT_NGRAM_COUNT="$OPT_NGRAM_COUNT"' -kndiscount'
      else
        # use absolute discount values
        OPT_NGRAM_COUNT="$OPT_NGRAM_COUNT"' -kndiscount '"$CDISCOUNT"
      fi
      ;;
    # no / unknown smoothing method -> fallback to MLE
    *)
      OPT_NGRAM_COUNT="$OPT_NGRAM_COUNT"' -cdiscount '"$CDISCOUNT"
      ;;
  esac
  
  # interpolation
  if [ "$SMOOTHING" == "INTERPOLATION" ]; then
    OPT_NGRAM_COUNT="$OPT_NGRAM_COUNT"' -interpolate'
  fi
  
  echo "$SRILM_BIN/ngram-count $OPT_NGRAM_COUNT"
  $SRILM_BIN/ngram-count $OPT_NGRAM_COUNT
}

