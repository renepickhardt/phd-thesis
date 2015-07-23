#!/bin/bash

declare -A ULMA_TOOLKITS=([srilm]="srilm.sh" [kylm]="kylm.sh")

# http://stackoverflow.com/questions/192292/bash-how-best-to-include-other-scripts
function loadCurrentDir {
  DIR_ULMA="${BASH_SOURCE%/*}"
  if [[ ! -d "$DIR_ULMA" ]]; then DIR_ULMA="$PWD"; fi
}

# Prints the usage of the ULMA API via command line.
function printUsage {
  echo 'Usage:'
  echo 'TODO: Insert usage'
}

# Checks if a valid toolkit was specified.
function checkValidToolkit {
  if [ ${ULMA_TOOLKITS["$1"]+_} ]; then return 0; else return 1; fi
}

# Prints the toolkits that are available.
function printToolkits {
  for tk in "${!ULMA_TOOLKITS[@]}"; do
    TKS="$TKS"", '$tk'"
  done
  TKS=${TKS:2}
  echo 'Valid toolkit choices are: '"$TKS"
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
  SOURCED=$( [ -z $ULMA_TOOLKIT ] )
  
  while [[ $# > 0 ]]
  do
    key="$1"
    case $key in
      # help
      -h|--help)
      printUsage
      exit 0
      ;;
      # toolkit
      -t|--toolkit)
      ULMA_TOOLKIT=$2
      shift
      ;;
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
  
  if [ -z $ULMA_TOOLKIT ]; then
    echo 'Too few arguments! Please specify the toolkit you want to use.'
    printToolkits
    return 2
  fi
  if checkValidToolkit $ULMA_TOOLKIT; then
    if [ ! $SOURCED ]; then
      source "$DIR_ULMA"/${ULMA_TOOLKITS[$ULMA_TOOLKIT]}
    fi
  else
    echo 'There is no such toolkit '"'$ULMA_TOOLKIT'!"
    printToolkits
    return 3
  fi
  
  if [ -z $INPUT_FILE ]; then
    echo 'Too few arguments! Please specify an input file.'
    return 4
  fi
  
  if [ -z $OUTPUT_FILE ]; then
    echo 'Too few arguments! Please specify an output file.'
    return 5
  elif [ -a $OUTPUT_FILE ]; then
    read -p 'Warning: The output file '"'"$OUTPUT_FILE"'"' already exists. Do you wish to override it? ' yn
    case $yn in
        [Yy]*)
          # override output file
          ;;
        *)
          echo 'Operation aborted by user.'
          return 5
          ;;
    esac
  fi
  
  # check for valid order
  if [ -z $ORDER ]; then
    echo 'Too few arguments! Please provide a N-Gram order using e.g. '"'"'-n'"'"'.'
    return 6
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

loadCurrentDir
parseArguments "$@"
ERRCODE="$?"
if [ "$ERRCODE" -ne "0" ]; then
  echo 'Use the '"'-h'"' switch for help.'
  exit "$ERRCODE"
else
  lmplz
fi

