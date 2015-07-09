# SRILM
SRILM is a toolkit for building and applying statistical language models.

It supports
* Good-Turing (default),
* Witten-Bell `-wbdiscount<n>`,
* Kneser-Ney `-ukndiscount`,
* modified Kneser-Ney `-kndiscount<n>`,
* Ney's absolute discounting `-cdiscount<n>` and
* Ristad's natural discounting `-ndiscount<n>`.

SRILM can fix ARPA files via `ngram -order N -lm input -write-lm output`.

## Native Usage
* interpolation supported with u/m Kneser-Ney, Witten-Bell and absolute discounting

### Export smoothed language model to ARPA file

    # disables Good-Turing discounting for all n-grams
    ngram-count -text sentences.txt -no-sos -no-eos -order ORDER -lm model.arpa -gt1max 0 -gt2max 0 -gt3max 0 -gt4max 0 -gt5max 0 -gt6max 0 -gt7max 0 -gt8max 0 -gt9max 0 -gtmax 0

