#!/bin/bash

# variable initialization section
ORDER=0
CLEAR=false
QUERY=false
GENERATE_TABLE=false
MODELS=()
## program binary directories
ULMA=/glmtk/ulma
KENLM=/glmtk/kenlm/bin
SRILM=/glmtk/srilm-1.7.1/bin/i686-m64
## other directories
OUTPUT_DIR=overview
WORKING_DIR=/tmp

# Prints the usage of the script in case of using the help command.
function printUsage {
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

# Generates the model name depending on the parameters used to create it.
function get_model_name {
  local TOOL="$1"
  shift
  local ESTIMATOR=mle
  local INTERPOLATE=false
  local CDISCOUNT=0
  local SEOS=false
  while [[ $# > 0 ]]; do
    key="$1"
    case $key in
      # Kneser-Ney smoothing
      -kn)
        ESTIMATOR=kn
        ;;
      # Modified Kneser-Ney smoothing
      -mkn)
        ESTIMATOR=mkn
        ;;
      # interpolate
      -i)
        INTERPOLATE=true
        ;;
      # absolute discounting
      -cdiscount)
        CDISCOUNT="$2"
        shift
        ;;
      # start-/end-of-sentence tokens
      -seos)
        SEOS=true
        ;;
    esac
    shift
  done
  
  local FILENAME="$TOOL"_"$ESTIMATOR"
  if $INTERPOLATE; then
    FILENAME="$FILENAME"_interpolated
  fi
  if [ ! "$CDISCOUNT" = "0" ]; then
    FILENAME="$FILENAME"_cdis-"$CDISCOUNT"
  fi
  if $SEOS; then
    FILENAME="$FILENAME"_seos
  fi
  FILENAME="$FILENAME"-"$ORDER"
  
  echo "$FILENAME"
}

# Adds a model to the LMOG processing queue.
function add_model {
  local PARAMS="$@"
  MODELS+=( "$PARAMS" )
}

# Adds all the models to the LMOG processing queue.
# Add new language models by adding an entry using the tool and the parameters here!
function add_models {
  # KenLM
  add_model kenlm -i -mkn
  # KyLM
  add_model kylm -seos -i 
  add_model kylm -seos -i -kn
  add_model kylm -seos -i -mkn
  # SRILM
  ## non-seos
  add_model srilm
  add_model srilm -cdiscount 0.75 -i
  add_model srilm -kn
  add_model srilm -i -kn
  add_model srilm -i -mkn
  ## with seos
  add_model srilm -seos
  add_model srilm -seos -cdiscount 0.75 -i
  add_model srilm -seos -kn
  add_model srilm -seos -i -kn
  add_model srilm -seos -i -mkn
}

# Creates the language models that are missing.
function create_models {
  local PARAMS=
  local MODEL=
  for ((i = 0; i < ${#MODELS[@]}; i++)); do
    PARAMS=${MODELS[$i]}
    MODEL_NAME=$( get_model_name $PARAMS )
    MODEL_PATH="$DIR_LM"/"$MODEL_NAME".arpa
    
    if [ ! -f "$MODEL_PATH" ]; then
      "$ULMA"/ulma.sh -t $PARAMS -n "$ORDER" "$CORPUS" "$MODEL_PATH"
    fi
  done
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
  local RESULT="$2"
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
  local MODEL="$1"
  local RESULT="$2"
  
  "$SRILM"/ngram -lm "$MODEL" -counts "$QRY_SRILM" -debug 2 > "$RESULT"
}

# Queries all the language models.
function query {
  for ((i = 0; i < ${#MODELS[@]}; i++)); do
    local PARAMS=${MODELS[$i]}
    local MODEL_NAME=$( get_model_name $PARAMS )
    local MODEL_PATH="$DIR_LM"/"$MODEL_NAME".arpa
    local QUERY_PATH="$DIR_QRES"/"$MODEL_NAME".txt
    
    #TODO WTF is there a better way to access the tool name?
    for PARAM in ${PARAMS[@]}; do
      # skip existing query results
      if [ -f "$QUERY_PATH" ]; then
        break
      fi
      # skip missing models
      if [ ! -f "$MODEL_PATH" ]; then
        echo '[Warning] Skipping missing language model '"'$PARAMS'"'.'
        break
      fi
      
      if [ "$PARAM" = "srilm" ]; then
        # SRILM
        query_srilm "$MODEL_PATH" "$QUERY_PATH"
      elif [ "$PARAM" = "kenlm" ]; then
        # KenLM
        ## generate binary file for faster queries
        local KENLM_MODEL_PATH="$DIR_LM"/"$MODEL_NAME".bin
        if [ ! -f "$KENLM_MODEL_PATH" ]; then
          "$KENLM"/build_binary "$MODEL_PATH" "$KENLM_MODEL_PATH"
        fi
        
        #TODO not THAT nice
        ## non-seos
        query_kenlm "$KENLM_MODEL_PATH" "$QUERY_PATH"
        ## with seos
        QUERY_PATH_SEOS="$DIR_QRES"/"$MODEL_NAME"_seos.txt
        query_kenlm "$KENLM_MODEL_PATH" "$QUERY_PATH_SEOS" seos
      else
        # KyLM
        echo 'KyLM querying is not implemented yet.'
      fi
      
      break
    done
  done
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
DIR="$OUTPUT_DIR"/"${CORPUS##*/}"
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

add_models

# create vocabulary if missing
if [ ! -f "$VOCAB_FILE" ]; then
  create_vocab
fi

# create missing language models
echo '[PHASE] generate missing language models...'
create_models

if $QUERY; then
  # create missing query files
  echo '[PHASE] generate missing query files...'
  create_query_files
  
  # query the language models
  echo '[PHASE] querying language models...'
  query
fi

# generate the overview table
if $GENERATE_TABLE; then
  echo '[PHASE] generating overview table...'
  create_table "$TABLE_FILE"
fi

echo '[INFO] Done. You can find the generated files in the output directory '"'$OUTPUT_DIR'"'.'

