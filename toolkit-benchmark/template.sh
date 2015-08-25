#!/bin/bash

# variable initialization section
ORDER=0
CLEAR=false
QUERY=false
GENERATE_TABLE=false
ESTIMATORS=( mle kn mkn )
## program binary directories
ULMA=/glmtk/ulma
KENLM=/glmtk/kenlm/bin
SRILM=/glmtk/srilm-1.7.1/bin/i686-m64
## other directories
WORKING_DIR=/tmp

# Prints the usage of the script in case of using the help command.
function printUsage {
  # TODO
  echo 'LMOG (language model overview generator)'
  echo 'Creates language models using different language model toolkits and generates an overview table with some statistics - in order to derive their correctness.'
  echo
  echo 'Usage: ./lmog.sh [OPTIONS] CORPUS'
  echo
  echo 'LMOG uses a corpus to create language models using different toolkits.'
  echo 'Optionally these models are queried with every sequence that is possible with the corpus vocabulary.'
  echo 'LMOG then generates an overview table that shows some statistics for each toolkit:'
  echo '* the sum of all probabilities'
  echo
  echo 'All the files generated will be in '"'overview/<CORPUS>/'"'.'
  echo
  echo 'Options:'
  echo '-h, --help    Displays this help message.'
  echo '-n, --order   The order of the n-gram models that should be created.'
  echo '              (defaults to 2)'
  echo '-q, --query   Query the language models.'
  echo 'Other Options:'
  echo '-c, --clear   Clear the output directory. Everything LMOG needs to operate will be recreated automatically betimes.'
  echo '-t, --table   Generate an overview table. This option will be set automatically, if you query the language models using the option '"'-q' or '--query'"'.'
}

# Parses the startup arguments into variables.
function parseArguments {
  while [[ $# > 0 ]]; do
    key="$1"
    case $key in
      # help
      -h|--help)
      printUsage
      exit 0
      ;;
      # order
      -n|--order)
      shift
      ORDER="$1"
      ;;
      # query the language models
      # * create model binaries if not existing
      # * create query files if not existing
      # * query the models
      -q|--query)
      QUERY=true
      GENERATE_TABLE=true
      ;;
      # clear output data of current corpus
      -c|--clear)
      CLEAR=true
      ;;
      # generate an overview table
      -t|--table)
      GENERATE_TABLE=true
      ;;
      # unknown option
      -*)
      echo 'Unknown option '"'$key'"'!'
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

  # check for valid parameters
  if [ -z "$CORPUS" ]; then
    echo '[ERROR] Too few arguments! Please provide a corpus file.'
    return 1
  elif [ ! -f "$CORPUS" ]; then
    echo '[ERROR] There is no such corpus file '"'$CORPUS'"'!'
    return 2
  fi
  
  if [ "$ORDER" -eq "0" ]; then
    ORDER=2
    echo '[INFO] Using default order n = 2.'
  fi
}

# Handles the parameters (arguments that aren't an option) and checks if their count is valid.
function handleParameter {
  # 1. corpus file
  if [ -z "$CORPUS" ]; then
    CORPUS="$1"
  else
    return 1
  fi
  
  # too many parameters
  return 0
}

# main script function section

# Uses SRILM to create the corpus' vocabulary for the given order.
function create_vocab {
  #TODO remove pause tags '-pau-', disable unknown words (and seos?)
  "$SRILM"/ngram-count -order "$ORDER" -write-vocab "$VOCAB_FILE" -text "$CORPUS"
}

function ulma {
  local EXT=arpa
  local TOOL="$1"
  local PARAMS="$2"
  local MODEL="$3"-"$ORDER"."$EXT"
  
  if [ ! -f "$MODEL" ]; then
    if [ ! -z "$PARAMS" ]; then
      "$ULMA"/ulma.sh -t "$TOOL" -n "$ORDER" $PARAMS "$CORPUS" "$MODEL"
    else
      "$ULMA"/ulma.sh -t "$TOOL" -n "$ORDER" "$CORPUS" "$MODEL"
    fi
  fi
}

# Creates the language models that are missing.
function create_models {
  # KenLM
  local KENLM_MKN="$DIR_LM"/kenlm_mkn
  ulma 'kenlm' '-i -mkn' "$KENLM_MKN"
  # KyLM
  local KYLM_MLE_SEOS="$DIR_LM"/kylm_mle_seos
  local KYLM_KN_SEOS="$DIR_LM"/kylm_kn_seos
  local KYLM_MKN_SEOS="$DIR_LM"/kylm_mkn_seos
  ulma 'kylm' '-i -seos' "$KYLM_MLE_SEOS"
  ulma 'kylm' '-i -kn -seos' "$KYLM_KN_SEOS"
  ulma 'kylm' '-i -mkn -seos' "$KYLM_MKN_SEOS"
  # SRILM
  #TODO repeat with -cdiscount 0.75 -interpolate -no-sos -no-eos
  ## non-seos
  local SRILM_MLE="$DIR_LM"/srilm_mle
  local SRILM_KN="$DIR_LM"/srilm_kn
  local SRILM_KN_I="$DIR_LM"/srilm_kn_i
  local SRILM_MKN="$DIR_LM"/srilm_mkn
  ulma 'srilm' '' "$SRILM_MLE"
  ulma 'srilm' '-kn' "$SRILM_KN"
  ulma 'srilm' '-i -kn' "$SRILM_KN_I"
  ulma 'srilm' '-i -mkn' "$SRILM_MKN"
  ## with seos
  local SRILM_MLE_SEOS="$DIR_LM"/srilm_mle_seos
  local SRILM_KN_SEOS="$DIR_LM"/srilm_kn_seos
  local SRILM_KN_I_SEOS="$DIR_LM"/srilm_kn_i_seos
  local SRILM_MKN_SEOS="$DIR_LM"/srilm_mkn_seos
  ulma 'srilm' '' "$SRILM_MLE_SEOS"
  ulma 'srilm' '-kn -seos' "$SRILM_KN_SEOS"
  ulma 'srilm' '-i -kn -seos' "$SRILM_KN_I_SEOS"
  ulma 'srilm' '-i -mkn -seos' "$SRILM_MKN_SEOS"
}

# Creates the query files for KenLM (mandatory as other depend on it) and SRILM.
function create_query_files {
  # abort if all query files existing
  if [ -f "$QRY_KENLM" ] && [ -f "$QRY_SRILM" ]; then
    return 0
  fi
  
  local CRR="$WORKING_DIR"/kenlm-query
  local NEXT="$TMP".tmp
  
  # clear query file
  if [ -a "$CRR" ]; then
    >"$CRR"
  fi
  
  # create KenLM query file (basis)
  i=1
  while [ "$i" -le "$ORDER" ]; do
    if [ "$i" -eq "1" ]; then
      echo 'Step 1/'"$ORDER"': Use the vocabulary as query file basis.'
    else
      echo 'Step '"$i"'/'"$ORDER"': Expand query file by vocabulary.'
    fi
    
    if [ -a "$NEXT" ]; then
      >"$NEXT"
    else
      touch "$NEXT"
    fi
    
    if [ ! -s "$CRR" ]; then
      cp "$VOCAB_FILE" "$NEXT"
    else
      while read line; do
        awk '{print $0" '"$line"'"}' "$CRR" >> "$NEXT"
      done <"$VOCAB_FILE"
    fi
    
    mv "$NEXT" "$CRR"
    let i=i+1
  done
  
  # create SRILM query file and copy files from working dir to destinations
  echo 'finishing SRILM query file...'
  awk '{print $0" 1"}' "$CRR" > "$QRY_SRILM"
  mv "$CRR" "$QRY_KENLM"
}

# Queries a language model using KenLM.
function query_kenlm {
  local MODEL="$1"
  local RESULT="$2"-"$ORDER".txt
  local SEOS=false
  if [ ! -z "$3" ]; then
    SEOS=true
  fi
  
  if ! $SEOS; then
    "$KENLM"/query -n "$MODEL" <"$QRY_KENLM" > "$RESULT"
  else
    "$KENLM"/query "$MODEL" <"$QRY_KENLM" > "$RESULT"
  fi
}

# Queries a language model using SRILM.
function query_srilm {
  local MODEL="$1"-"$ORDER".arpa
  local RESULT="$2"-"$ORDER".txt
  
  "$SRILM"/ngram -lm "$MODEL" -counts "$QRY_SRILM" -debug 2 > "$RESULT"
}

# Queries all the language models.
function query {
  #TODO use different query files for non-seos?
  
  # KenLM
  ## generate binary file for faster queries
  local KENLM_MKN="$DIR_LM"/kenlm_mkn-"$ORDER".arpa
  local KENLM_MKN_BIN="$DIR_LM"/kenlm_mkn-"$ORDER".bin
  if [ ! -f "$KENLM_MKN_BIN" ]; then
    "$KENLM"/build_binary "$KENLM_MKN" "$KENLM_MKN_BIN"
  fi
  ## non-seos
  local QRES_KENLM_MKN="$DIR_QRES"/kenlm_mkn
  query_kenlm "$KENLM_MKN_BIN" "$QRES_KENLM_MKN"
  ## with seos
  local QRES_KENLM_MKN_SEOS="$DIR_QRES"/kenlm_mkn_seos
  query_kenlm "$KENLM_MKN_BIN" "$QRES_KENLM_MKN_SEOS" seos
  
  # KyLM
  #TODO
  
  # SRILM
  ## non-seos
  local SRILM_MLE="$DIR_LM"/srilm_mle
  local QRES_SRILM_MLE="$DIR_QRES"/srilm_mle
  query_srilm "$SRILM_MLE" "$QRES_SRILM_MLE"
  local SRILM_KN="$DIR_LM"/srilm_kn
  local QRES_SRILM_KN="$DIR_QRES"/srilm_kn
  query_srilm "$SRILM_KN" "$QRES_SRILM_KN"
  local SRILM_KN_I="$DIR_LM"/srilm_kn_i
  local QRES_SRILM_KN_I="$DIR_QRES"/srilm_kn_i
  query_srilm "$SRILM_KN_I" "$QRES_SRILM_KN_I"
  local SRILM_MKN="$DIR_LM"/srilm_mkn
  local QRES_SRILM_MKN="$DIR_QRES"/srilm_mkn
  query_srilm "$SRILM_MKN" "$QRES_SRILM_MKN"
  ## with seos
  local SRILM_MLE_SEOS="$DIR_LM"/srilm_mle_seos
  local QRES_SRILM_MLE_SEOS="$DIR_QRES"/srilm_mle_seos
  query_srilm "$SRILM_MLE_SEOS" "$QRES_SRILM_MLE_SEOS"
  local SRILM_KN_SEOS="$DIR_LM"/srilm_kn_seos
  local QRES_SRILM_KN_SEOS="$DIR_QRES"/srilm_kn_seos
  query_srilm "$SRILM_KN_SEOS" "$QRES_SRILM_KN_SEOS"
  local SRILM_KN_I_SEOS="$DIR_LM"/srilm_kn_i_seos
  local QRES_SRILM_KN_I_SEOS="$DIR_QRES"/srilm_kn_i_seos
  query_srilm "$SRILM_KN_I_SEOS" "$QRES_SRILM_KN_I_SEOS"
  local SRILM_MKN_SEOS="$DIR_LM"/srilm_mkn_seos
  local QRES_SRILM_MKN_SEOS="$DIR_QRES"/srilm_mkn_seos
  query_srilm "$SRILM_MKN_SEOS" "$QRES_SRILM_MKN_SEOS"
}

# Calculates sum(p) in the SRILM query results.
function sump_srilm {
  local RESULT="$1"
  
  # skip missing query result files
  if [ ! -f "$RESULT" ]; then
    echo 'n/a'
    return 0
  fi
  
  local COLUMN=6
  let COLUMN=COLUMN+"$ORDER"
  local SUMP=$( head -n -5 "$RESULT" | awk '{p=p+($'"$COLUMN"')} END{print p}' )
  echo "$SUMP"
}

# Adds a tool's line to the table, generated from an array of probabilities.
function add_table_line {
  local TABLE="$1"
  local TOOL="$2"
  # probability array: $3
  
  declare -a probs=("${!3}")
  L_LINE='| '"$TOOL"' |'
  for p in "${probs[@]}"; do
    L_LINE="$L_LINE"' '"$p"' |'
  done
  echo "$L_LINE" >> "$TABLE"
}

# Generates an overview table using the query result files.
function create_table {
  #TODO unk
  local TABLE="$1"
  
  # table header
  echo '| Toolkit | MLE | MLE (seos) | KN | KN (seos) | MKN | MKN (seos) |' > "$TABLE"
  echo '| ------- | --- | ---------- | -- | --------- | --- | ---------- |' >> "$TABLE"
  
  # SRILM
  L_TOOL=SRILM
  L_P_LINE=()
  for estimator in "${ESTIMATORS[@]}"; do
    L_P=$( sump_srilm "$DIR_QRES"/"${L_TOOL,,}"'_'"$estimator"'-'"$ORDER"'.txt' )
    L_P_LINE+=( "$L_P" )
    L_P_seos=$( sump_srilm "$DIR_QRES"/"${L_TOOL,,}"'_'"$estimator"'_seos-'"$ORDER"'.txt' )
    L_P_LINE+=( "$L_P_seos" )
  done
  add_table_line "$TABLE" "$L_TOOL" L_P_LINE[@]
  
  echo '' >> "$TABLE"
  echo '## Legend' >> "$TABLE"
  echo 'seos: with start-/end-of-sentence tags enabled' >> "$TABLE"
}


# entry point
parseArguments "$@"
SUCCESS=$?
if [ "$SUCCESS" -ne 0 ]; then
  echo 'Use the '"'-h'"' switch for help.'
  exit "$SUCCESS"
fi

# execute main script functions
DIR=overview/"${CORPUS##*/}"
DIR_LM="$DIR"/lm
DIR_QREQ="$DIR"/query/request
DIR_QRES="$DIR"/query/result
VOCAB_FILE="$DIR"/vocabulary.txt
TABLE_FILE="$DIR"/table-"$ORDER".md

QRY_KENLM="$DIR_QREQ"/kenlm-"$ORDER".txt
QRY_SRILM="$DIR_QREQ"/srilm-"$ORDER".txt

# clear output directory
if $CLEAR; then
  rm -rf "$DIR"
  echo '[INFO] Output directory has been cleared.'
fi
# build output directory structure if necessary
if [ ! -d "$DIR_LM" ]; then
  mkdir -p "$DIR_LM"
fi
if [ ! -d "$DIR_QREQ" ]; then
  mkdir -p "$DIR_QREQ"
fi
if [ ! -d "$DIR_QRES" ]; then
  mkdir -p "$DIR_QRES"
fi

# create vocabulary if missing
if [ ! -f "$VOCAB_FILE" ]; then
  create_vocab
fi

# create missing language models
create_models

if $QUERY; then
  # create missing query files
  create_query_files
  
  # query the language models
  query
fi

# generate the overview table
if $GENERATE_TABLE; then
  create_table "$TABLE_FILE"
fi

