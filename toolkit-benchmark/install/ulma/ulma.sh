#!/bin/bash

# Prints the usage of the ULMA API via command line.
function printUsage {
  echo 'Usage:'
  echo 'TODO: Insert usage'
}

# Extracts the arguments of an ULMA command line call with format:
# INPUT_FILE [OPTIONS] OUTPUT_FILE
#
# Uses global variables to store the arguments:
# * SMOOTHING_METHOD [KN|MKN]
# * SMOOTHING=BACKOFF [BACKOFF|INTERPOLATION]
# * INPUT_FILE
# * OUTPUT_FILE
function parseArguments {
  SMOOTHING=BACKOFF
  SOS=false
  EOS=false
  
  while [[ $# > 0 ]]
  do
    key="$1"
    case $key in
      # ngram count (order)
      -n|--order)
      ORDER=$2
      shift
      ;;
      # smoothing method
      -kn|--kneser_ney)
      SMOOTHING_METHOD=KN
      ;;
      -mkn|--modified_kneser_ney)
      SMOOTHING_METHOD=MKN
      ;;
      # smoothing options
      -i|--interpolation)
      ## switch from backoff to interpolation
      SMOOTHING=INTERPOLATION
      ;;
      -seos|--start-end-of-sentence)
      ## enable start-/end-of-sentence tags
      SOS=true
      EOS=true
      ;;
      # unknown option
      -*)
        echo 'Unknown option' "'""$key""'"'!'
        return 1
        ;;
      # parameter
      *)
        if ! handleParameter "$1"; then
          echo 'Too many arguments!'
          return 1
        fi
      ;;
    esac
    shift
  done
  
  if [ -z $OUTPUT_FILE ]; then
    echo 'Too few arguments! Please specify an output file.'
    return 1
  elif [ -a $OUTPUT_FILE ]; then
    read -p 'Warning: The output file '"'"$OUTPUT_FILE"'"' already exists. Do you wish to override it? ' yn
    case $yn in
        [Yy]*)
          # override output file
          ;;
        *)
          echo 'Operation aborted by user.'
          exit 2
          ;;
    esac
  fi
  
  # check for valid order
  if [ -z $ORDER ]; then
    echo 'N-Gram order is missing! Please provide an order using e.g. '"'"'-n'"'"'.'
    return 1
  fi
  
  # enforce interpolation when using MKN
  if [ "$SMOOTHING_METHOD" == "MKN" ] && [ "$SMOOTHING" != "INTERPOLATION" ]; then
    SMOOTHING=INTERPOLATION
    echo "Warning: Interpolation was enforced, due to the usage of the Modified Kneser Ney estimator."
  fi
}

# Handles a parameter in an ULMA command line call.
function handleParameter {
  # first argument: input file
  if [ -z ${INPUT_FILE} ]; then
    INPUT_FILE="$key"
  # second argument: output file
  elif [ -z ${OUTPUT_FILE} ]; then
    OUTPUT_FILE="$key"
  # too many arguments
  else
    return 1
  fi
  return 0
}

if ! parseArguments "$@"; then
  printUsage
  exit 1
fi

