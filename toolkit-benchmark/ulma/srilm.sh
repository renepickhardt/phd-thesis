#!/bin/bash
# ULMA.SRILM
#
# This script is part of the ULMA API (TODO).
# It is a wrapper for the SRILM toolkit, to provide an endpoint for ULMA users.
#
# Authors: Sebastian Schlicht
#

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
  OPT_NGRAM_COUNT='-text '$INPUT_FILE' -order '$ORDER
  
  # start-/end-of-sentence tags
  if ! $SOS; then
    OPT_NGRAM_COUNT=$OPT_NGRAM_COUNT' -no-sos'
  fi
  if ! $EOS; then
    OPT_NGRAM_COUNT=$OPT_NGRAM_COUNT' -no-eos'
  fi
  OPT_NGRAM_COUNT=$OPT_NGRAM_COUNT' -lm '$OUTPUT_FILE
  
  # smoothing method
  case $SMOOTHING_METHOD in
    KN)
      # TODO
      OPT_NGRAM_COUNT=$OPT_NGRAM_COUNT' -ukndiscount'
      ;;
    MKN)
      # TODO
      OPT_NGRAM_COUNT=$OPT_NGRAM_COUNT' -kndiscount'
      ;;
    # no / unknown smoothing method -> fallback to MLE
    *)
      OPT_NGRAM_COUNT=$OPT_NGRAM_COUNT' -cdiscount 0'
      ;;
  esac
  
  # interpolation
  if [ "$SMOOTHING" == "INTERPOLATION" ]; then
    OPT_NGRAM_COUNT=$OPT_NGRAM_COUNT' -interpolate'
  fi
  
  echo $OPT_NGRAM_COUNT
  #$(ngram-count $OPT_NGRAM_COUNT)
}

