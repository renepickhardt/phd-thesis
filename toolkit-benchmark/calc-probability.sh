#!/bin/bash
TRAINING_FILE=training.txt
MAX_ORDER="$1"
ESTIMATORS=( mle kn mkn )

if [ -z "$MAX_ORDER" ] || [ "$MAX_ORDER" -lt "1" ]; then
  echo 'Please pass an order (higher than zero)!'
  exit 1
fi

# use SRILM to create vocabulary
function create_vocab {
  #TODO WTF is "-pau-" that is added by SRILM?
  srilm-1.7.1/bin/*/ngram-count -order "$ORDER" -write-vocab "$VOCAB_FILE" -text "$TRAINING_FILE"
}

# create all the language models
function create_models {
  #TODO renew ULMA API: -mle -text CORPUS -write-lm MODEL
  ## KenLM (nseos during querying)
  ulma/ulma.sh -t "kenlm" -n "$ORDER" -i -mkn "$TRAINING_FILE" overview/lm/kenlm_mkn-"$ORDER".arpa
  #TODO doesn't work for n=1
  kenlm/bin/build_binary overview/lm/kenlm_mkn-"$ORDER".arpa overview/lm/kenlm_mkn-"$ORDER".bin
  ## KyLM (doesn't support to disable seos, doesn't support backoff)
  ulma/ulma.sh -t "kylm" -n "$ORDER" -i -seos "$TRAINING_FILE" overview/lm/kylm_mle_seos-"$ORDER".arpa
  ulma/ulma.sh -t "kylm" -n "$ORDER" -i -kn -seos "$TRAINING_FILE" overview/lm/kylm_kn_seos-"$ORDER".arpa
  ulma/ulma.sh -t "kylm" -n "$ORDER" -i -mkn -seos "$TRAINING_FILE" overview/lm/kylm_mkn_seos-"$ORDER".arpa
  ## SRILM
  ##TODO '-debug 2' prints counts and discount values
  ### no seos
  ulma/ulma.sh -t "srilm" -n "$ORDER" "$TRAINING_FILE" overview/lm/srilm_mle-"$ORDER".arpa
  ulma/ulma.sh -t "srilm" -n "$ORDER" -kn "$TRAINING_FILE" overview/lm/srilm_kn-"$ORDER".arpa -kn"$ORDER" overview/lm/srilm_kn-"$ORDER".txt
  ulma/ulma.sh -t "srilm" -n "$ORDER" -i -kn "$TRAINING_FILE" overview/lm/srilm_kn_interpolated-"$ORDER".arpa -kn"$ORDER" overview/lm/srilm_kn_interpolated-"$ORDER".txt
  ulma/ulma.sh -t "srilm" -n "$ORDER" -i -mkn "$TRAINING_FILE" overview/lm/srilm_mkn-"$ORDER".arpa -kn"$ORDER" overview/lm/srilm_mkn-"$ORDER".txt
  ### with seos
  ulma/ulma.sh -t "srilm" -n "$ORDER" -seos "$TRAINING_FILE" overview/lm/srilm_mle_seos-"$ORDER".arpa
  ulma/ulma.sh -t "srilm" -n "$ORDER" -kn -seos "$TRAINING_FILE" overview/lm/srilm_kn_seos-"$ORDER".arpa -kn"$ORDER" overview/lm/srilm_kn_seos-"$ORDER".txt
  ulma/ulma.sh -t "srilm" -n "$ORDER" -i -kn -seos "$TRAINING_FILE" overview/lm/srilm_kn_interpolated_seos-"$ORDER".arpa -kn"$ORDER" overview/lm/srilm_kn_interpolated-"$ORDER".txt
  ulma/ulma.sh -t "srilm" -n "$ORDER" -i -mkn -seos "$TRAINING_FILE" overview/lm/srilm_mkn_seos-"$ORDER".arpa -kn"$ORDER" overview/lm/srilm_mkn_seos-"$ORDER".txt
}

# create query files
function expand_query_file {
  # combine each line of vocabulary with each query file line
  TMP_FILE="$1"
  QUERY_FILE="$2"
  
  if [ -a "$TMP_FILE" ]; then
    >"$TMP_FILE"
  else
    touch "$TMP_FILE"
  fi
  
  if [ ! -s "$QUERY_FILE" ]; then
    echo 'query file is empty, using vocabulary copy.'
    cp "$VOCAB_FILE" "$TMP_FILE"
  else
    echo 'expand query file by vocabulary...'
    while read line; do
      awk '{print $0" '"$line"'"}' "$QUERY_FILE" >> "$TMP_FILE"
    done <"$VOCAB_FILE"
  fi
  mv "$TMP_FILE" "$QUERY_FILE"
}
function create_query_files {
  QUERY_FILE=/tmp/kenlm-query
  TMP_FILE=/tmp/ulma-query.tmp
  
  if [ -a "$QUERY_FILE" ]; then
    >"$QUERY_FILE"
  fi
  
  i=0
  while [ "$i" -lt "$ORDER" ]; do
    expand_query_file "$TMP_FILE" "$QUERY_FILE"
    let i=i+1
  done

  echo 'finishing SRILM query file...'
  awk '{print $0" 1"}' "$QUERY_FILE" > "$QUERY_SRILM"
  mv "$QUERY_FILE" "$QUERY_KENLM"
}

function query_models {
  #TODO create query files for seos and non-seos mode
  ## KenLM
  ###TODO doesn't work for n=1
  ### no seos
  kenlm/bin/query -n overview/lm/kenlm_mkn-"$ORDER".bin <"$QUERY_KENLM" > "$QRES_DIR"/kenlm_mkn-"$ORDER".txt
  ### with seos
  kenlm/bin/query overview/lm/kenlm_mkn-"$ORDER".bin <"$QUERY_KENLM" > "$QRES_DIR"/kenlm_mkn_seos-"$ORDER".txt
  ## KyLM
  ###TODO no idea
  ## SRILM
  ### no seos
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_mle-"$ORDER".arpa -counts "$QUERY_SRILM" -debug 2 > "$QRES_DIR"/srilm_mle-"$ORDER".txt
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_kn-"$ORDER".arpa -counts "$QUERY_SRILM" -debug 2 > "$QRES_DIR"/srilm_kn-"$ORDER".txt
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_kn_interpolated-"$ORDER".arpa -counts "$QUERY_SRILM" -debug 2 > "$QRES_DIR"/srilm_kn_interpolated-"$ORDER".txt
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_mkn-"$ORDER".arpa -counts "$QUERY_SRILM" -debug 2 > "$QRES_DIR"/srilm_mkn-"$ORDER".txt
  ### with seos
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_mle_seos-"$ORDER".arpa -counts "$QUERY_SRILM" -debug 2 > "$QRES_DIR"/srilm_mle_seos-"$ORDER".txt
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_kn_seos-"$ORDER".arpa -counts "$QUERY_SRILM" -debug 2 > "$QRES_DIR"/srilm_kn_seos-"$ORDER".txt
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_kn_interpolated_seos-"$ORDER".arpa -counts "$QUERY_SRILM" -debug 2 > "$QRES_DIR"/srilm_kn_interpolated_seos-"$ORDER".txt
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_mkn_seos-"$ORDER".arpa -counts "$QUERY_SRILM" -debug 2 > "$QRES_DIR"/srilm_mkn_seos-"$ORDER".txt
}

function calc_p_kenlm {
  if [ ! -r $1 ]; then
    echo 'n/a'
    return 0
  fi
  
  #TODO calculate sum(p) using query result file
}
function calc_p_kylm {
  if [ ! -r $1 ]; then
    echo 'n/a'
    return 0
  fi
  
  #TODO calculate sum(p) using query result file
}
function calc_p_srilm {
  if [ ! -r $1 ]; then
    echo 'n/a ('"$1"')'
    return 0
  fi
  
  #TODO p may be in column 8+$ORDER instead of fixed column #9
  # remove last 5 lines (statistics incl. ppl)
  # 9th column is p (base:10)
  local COLUMN=7+"$ORDER"
  P=$( head -n -5 "$1" | awk '{p=p+(10 ^ $'"$COLUMN"')} END{print p}' )
  echo "$P"
}
function create_table_header {
  echo '| Toolkit | MLE | MLE (seos) | KN | KN (seos) | MKN | MKN (seos) |' > "$1"
  echo '| ------- | --- | ---------- | -- | --------- | --- | ---------- |' >> "$1"
}
function create_table_line {
  declare -a probs=("${!3}")
  L_LINE='| '"$2"' |'
  for p in "${probs[@]}"; do
    L_LINE="$L_LINE"' '"$p"' |'
  done
  echo "$L_LINE" >> "$1"
}
function create_table {
  create_table_header "$1"
  #TODO print all perplexities from query result file

  # KenLM
  L_TOOL=KenLM
  L_P_LINE=()
  for estimator in "${ESTIMATORS[@]}"; do
    L_P=$( calc_p_kenlm 'overview/query/result/'"${L_TOOL,,}"'_'"$estimator"'-'"$ORDER"'.txt' )
    L_P_LINE+=("$L_P")
    L_P_seos=$( calc_p_kenlm 'overview/query/result/'"${L_TOOL,,}"'_'"$estimator"'_seos-'"$ORDER"'.txt' )
    L_P_LINE+=("$L_P_seos")
  done
  create_table_line "$1" "$L_TOOL" L_P_LINE[@]
  
  # KyLM
  L_TOOL=KyLM
  L_P_LINE=()
  for estimator in "${ESTIMATORS[@]}"; do
    L_P=$( calc_p_kylm 'overview/query/result/'"${L_TOOL,,}"'_'"$estimator"'-'"$ORDER"'.txt' )
    L_P_LINE+=( "$L_P" )
    L_P_seos=$( calc_p_kylm 'overview/query/result/'"${L_TOOL,,}"'_'"$estimator"'_seos-'"$ORDER"'.txt' )
    L_P_LINE+=( "$L_P_seos" )
  done
  create_table_line "$1" "$L_TOOL" L_P_LINE[@]
  
  # SRILM
  L_TOOL=SRILM
  L_P_LINE=()
  for estimator in "${ESTIMATORS[@]}"; do
    L_P=$( calc_p_srilm 'overview/query/result/'"${L_TOOL,,}"'_'"$estimator"'-'"$ORDER"'.txt' )
    L_P_LINE+=( "$L_P" )
    L_P_seos=$( calc_p_srilm 'overview/query/result/'"${L_TOOL,,}"'_'"$estimator"'_seos-'"$ORDER"'.txt' )
    L_P_LINE+=( "$L_P_seos" )
  done
  create_table_line "$1" "$L_TOOL" L_P_LINE[@]
  
  #TODO repeat for unk
  
  echo '' >> "$1"
  echo '## Legend' >> "$1"
  echo 'seos: with start-/end-of-sentence tags enabled' >> "$1"
}

rm -rf overview/*
mkdir overview/lm
mkdir -p overview/query/request
mkdir overview/query/result

ORDER=2
VOCAB_FILE=overview/training.txt.vocab

#TODO order doesn't seem relevant for vocabulary
create_vocab "$ORDER"

while [ "$ORDER" -le "$MAX_ORDER" ]; do
  #VOCAB_FILE=overview/training.txt-"$ORDER".vocab
  QUERY_SRILM=overview/query/request/srilm-"$ORDER".txt
  QUERY_KENLM=overview/query/request/kenlm-"$ORDER".txt
  QRES_DIR=overview/query/result
  
  create_models "$ORDER"
  create_query_files
  
  # query the probabilites of the vocabulary entries
  query_models
  # create table for current order
  create_table overview/table-"$ORDER".md
  
  let ORDER=ORDER+1
done

