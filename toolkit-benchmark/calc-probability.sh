#!/bin/bash
TRAINING_FILE=training.txt
VOCAB_FILE=training.txt.vocab
ORDER=1

# use SRILM to create vocabulary
function create_vocab {
  srilm-1.7.1/bin/*/ngram-count -order "$ORDER" -write-vocab "$VOCAB_FILE" -text "$TRAINING_FILE"
}
create_vocab

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
function create_query_file_srilm {
  awk '{print $0}' "$VOCAB_FILE" > /tmp/srilm-query
  awk '{print $0" 1"}' /tmp/srilm-query > "$1"
}
function create_query_file_kenlm {
  awk '{print $0}' "$VOCAB_FILE" > /tmp/kenlm-query
}
QUERY_SRILM=overview/query/srilm-"$ORDER".txt

create_query_file_srilm "$QUERY_SRILM"

# query the probabilites of the vocabulary entries

#for tool in "${TOOLS[@]}"; do
#  ulma/ulma.sh -t "$tool" query -n "$ORDER" -lm "$ESTIMATOR"_"$tool".arpa -q "$QUERY_FILE" > queries/"$ESTIMATOR"_"$tool".txt
#done

