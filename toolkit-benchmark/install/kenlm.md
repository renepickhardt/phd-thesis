# KenLM
KenLM estimates, filters, and queries language models.
Language models are estimated using modified Kneser-Ney smoothing without pruning.

## Native Usage
* pruning is supported `--prune sequenceWhere1IsYesForN` for non-unigrams
* "If the corpus contains a blank line, KenLM includes <s> </s> as a bigram."
* "As with all language model toolkits, tokenization and preprocessing should be done beforehand."

### Export smoothed language model to ARPA file

    bin/lmplz -o ORDER -S 80% -T /tmp <text >model.arpa

# Resources
* [Estimating](http://kheafield.com/code/kenlm/estimation/)

