#!/bin/bash
TRAINING_FILE=training.txt
MAX_ORDER="$1"

if [ -z "$MAX_ORDER" ] || [ "$MAX_ORDER" -lt "1" ]; then
  echo 'Please pass an order (higher than zero)!'
  exit 1
fi

# use SRILM to create vocabulary
function create_vocab {
  #TODO order relevant for vocabulary?
  srilm-1.7.1/bin/*/ngram-count -order "$ORDER" -write-vocab "$VOCAB_FILE" -text "$TRAINING_FILE"
}

# create all the language models
function create_models {
  #TODO adapt ULMA API or modify calls to match current API version
  ## KenLM (nseos during querying)
  ulma/ulma.sh -t "kenlm" -text "$TRAINING_FILE" -n "$ORDER" -mkn -write-lm overview/lm/kenlm_mkn-"$ORDER".arpa
  kenlm/bin/build_binary overview/lm/kenlm_mkn-"$ORDER".arpa overview/lm/kenlm_mkn-"$ORDER".bin
  ## KyLM (doesn't support to disable seos)
  ulma/ulma.sh -t "kylm" -text "$TRAINING_FILE" -n "$ORDER" -mle -seos -write-lm overview/lm/kylm_mle_seos-"$ORDER".arpa
  ulma/ulma.sh -t "kylm" -text "$TRAINING_FILE" -n "$ORDER" -kn -seos -write-lm overview/lm/kylm_kn_seos-"$ORDER".arpa
  ulma/ulma.sh -t "kylm" -text "$TRAINING_FILE" -n "$ORDER" -mkn -seos -write-lm overview/lm/kylm_mkn_seos-"$ORDER".arpa
  ## SRILM
  ### no seos
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -mle -write-lm overview/lm/srilm_mle-"$ORDER".arpa
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -kn -write-lm overview/lm/srilm_kn-"$ORDER".arpa
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -mkn -write-lm overview/lm/srilm_mkn-"$ORDER".arpa
  ### with seos
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -mle -seos -write-lm overview/lm/srilm_mle_seos-"$ORDER".arpa
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -kn -seos -write-lm overview/lm/srilm_kn_seos-"$ORDER".arpa
  ulma/ulma.sh -t "srilm" -text "$TRAINING_FILE" -n "$ORDER" -mkn -seos -write-lm overview/lm/srilm_mkn_seos-"$ORDER".arpa
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
  ## KenLM
  ### no seos
  kenlm/bin/query -n overview/lm/kenlm_mkn-"$ORDER".bin <"$QUERY_KENLM" > "$QRES_DIR"/kenlm_mkn-"$ORDER".txt
  ### with seos
  kenlm/bin/query overview/lm/kenlm_mkn-"$ORDER".bin <"$QUERY_KENLM" > "$QRES_DIR"/kenlm_mkn_seos-"$ORDER".txt
  ## KyLM
  #TODO no idea
  ## SRILM
  ### no seos
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_mle-"$ORDER".arpa -counts "$QUERY_SRILM" > "$QRES_DIR"/srilm_mle-"$ORDER".txt
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_kn-"$ORDER".arpa -counts "$QUERY_SRILM" > "$QRES_DIR"/srilm_kn-"$ORDER".txt
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_mkn-"$ORDER".arpa -counts "$QUERY_SRILM" > "$QRES_DIR"/srilm_mkn-"$ORDER".txt
  ### with seos
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_mle-"$ORDER".arpa -counts "$QUERY_SRILM" > "$QRES_DIR"/srilm_mle_seos-"$ORDER".txt
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_kn-"$ORDER".arpa -counts "$QUERY_SRILM" > "$QRES_DIR"/srilm_kn_seos-"$ORDER".txt
  srilm-1.7.1/bin/*/ngram -lm overview/lm/srilm_mkn-"$ORDER".arpa -counts "$QUERY_SRILM" > "$QRES_DIR"/srilm_mkn_seos-"$ORDER".txt
}

ORDER=1
VOCAB_FILE=overview/training.txt.vocab
while [ "$ORDER" -le "$MAX_ORDER" ]; do
  VOCAB_FILE=overview/training.txt-"$ORDER".vocab
  QUERY_SRILM=overview/query/request/srilm-"$ORDER".txt
  QUERY_KENLM=overview/query/request/kenlm-"$ORDER".txt
  QRES_DIR=overview/query/result
  
  create_vocab "$ORDER"
  create_models "$ORDER"
  create_query_files
  
  # query the probabilites of the vocabulary entries
  query_models
  
  let ORDER=ORDER+1
done

