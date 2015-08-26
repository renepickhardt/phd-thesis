#!/bin/bash
# ULMA.Kylm
#
# This script is part of the [ULMA API](https://github.com/sebschlicht/phd-thesis/blob/lm/toolkit-benchmark/ulma/ulma.md).
# It is a wrapper for the Kylm toolkit, to provide an endpoint for ULMA users.
#
# Authors: Sebastian Schlicht
#

KYLM_JAR=kylm-0.0.7/kylm-0.0.7.jar

# start argument parsing with toolkit set
if [ -z $ULMA_TOOLKIT ]; then
  ULMA_TOOLKIT=kylm
  source ulma.sh
fi

# Creates a language model using the current application parameter state.
#
# # Resources:
# * [Kylm documentation](http://www.phontron.com/kylm/)
function lmplz {
  OPT_COUNTNGRAMS="$INPUT_FILE"' -n '"$ORDER"
  
  # start-/end-of-sentence tags
  if ! $SOS || ! $EOS; then
    echo "[Error] Kylm doesn't support the absence of start- or end-of-sentence tags!"
    exit 99
  fi
  
  # smoothing method
  case $SMOOTHING_METHOD in
    KN)
      OPT_COUNTNGRAMS="$OPT_COUNTNGRAMS"' -kn'
      ;;
    MKN)
      OPT_COUNTNGRAMS="$OPT_COUNTNGRAMS"' -mkn'
      ;;
    # no / unknown smoothing method -> fallback to MLE
    *)
      OPT_COUNTNGRAMS="$OPT_COUNTNGRAMS"' -ml'
      ;;
  esac
  
  # discounting
  ## absolute discounting
  if [ ! "$CDISCOUNT" = "0" ]; then
    print_error 'Absolute discounting is not implemented yet.'
    exit 100
  fi
  
  # interpolation
  if [ "$SMOOTHING" != "INTERPOLATION" ]; then
    # TODO: or doesn't it support interploation?
    echo "[ERROR] Kylm doesn't support backoff!"
    exit 99
  fi
  
  OPT_COUNTNGRAMS="$OPT_COUNTNGRAMS"' -arpa '"$OUTPUT_FILE"
  
  java -cp "$KYLM_JAR" kylm.main.CountNgrams $OPT_COUNTNGRAMS
}

