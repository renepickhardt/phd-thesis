#!/bin/bash
TRAINING_FILE=training.txt
VOCAB_FILE=training.txt.vocab
ORDER="$1"

if [ -z "$ORDER" ] || [ "$ORDER" -lt "1" ]; then
  echo 'Please pass an order (higher than zero)!'
  exit 1
fi

# use SRILM to create vocabulary
function create_vocab {
  srilm-1.7.1/bin/*/ngram-count -order "$ORDER" -write-vocab "$VOCAB_FILE" -text "$TRAINING_FILE"
}
#create_vocab

# create all the language models
function create_models {
  ## KenLM (nseos during querying)
  ulma/ulma.sh -t "kenlm" -text "$TRAINING_FILE" -n "$ORDER" -mkn -write-lm overview/lm/kenlm_mkn.arpa
  ## KyLM (doesn't support to disable seos)
  ulma/ulma.sh -t "kylm" -text "$TRAINING_FILE" -n "$ORDER" -mle -seos -write-lm overview/lm/kylm_mle_seos.arpa
  ulma/ulma.sh -t "kylm" -text "$TRAINING_FILE" -n "$ORDER" -kn -seos -write-lm overview/lm/kylm_kn_seos.arpa
  ulma/ulma.sh -t "kylm" -text "$TRAINING_FILE" -n "$ORDER" -mkn -seos -write-lm overview/lm/kylm_mkn_seos.arpa
  ## SRILM
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -mle -write-lm overview/lm/srilm_mle.arpa
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -kn -write-lm overview/lm/srilm_kn.arpa
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -mkn -write-lm overview/lm/srilm_mkn.arpa
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -mle -seos -write-lm overview/lm/srilm_mle_seos.arpa
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -kn -seos -write-lm overview/lm/srilm_kn_seos.arpa
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -mkn -seos -write-lm overview/lm/srilm_mkn_seos.arpa
}
#create_models

# prepare language models for querying
function prepare_for_queries {
  kenlm/bin/build_binary overview/lm/kenlm_mkn.arpa overview/lm/kenlm_mkn.bin
}
#prepare_for_queries

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
QUERY_SRILM=overview/query/srilm-"$ORDER".txt
QUERY_KENLM=overview/query/kenlm-"$ORDER".txt
create_query_files

# query the probabilites of the vocabulary entries

#for tool in "${TOOLS[@]}"; do
#  ulma/ulma.sh -t "$tool" query -n "$ORDER" -lm "$ESTIMATOR"_"$tool".arpa -q "$QUERY_FILE" > queries/"$ESTIMATOR"_"$tool".txt
#done

