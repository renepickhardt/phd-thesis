# SRILM
SRILM is a toolkit for building and applying statistical language models.

It supports
* Good-Turing (default),
* Witten-Bell `-wbdiscount<n>`,
* Kneser-Ney `-ukndiscount`,
* modified Kneser-Ney `-kndiscount<n>`,
* Ney's absolute discounting `-cdiscount<n> <discount>` and
* Ristad's natural discounting `-ndiscount<n>`.

SRILM can fix ARPA files via `ngram -order N -lm input -write-lm output`.

## Native Usage
* interpolation supported with u/m Kneser-Ney, Witten-Bell and absolute discounting
* "Only absolute and Witten-Bell discounting currently support fractional counts."
* "Smoothing with -kndiscount or -ukndiscount has a side-effect on the N-gram counts, since the lower-order counts are destructively modified according to the KN smoothing approach (Kneser & Ney, 1995). The -write option will output these modified counts, and count cutoffs specified by -gtNmin operate on the modified counts, potentially leading to a different set of N-grams being retained than with other discounting methods. This can be considered either a feature or a bug."

### Export unsmoothed language model to ARPA file

    ngram-count -text sentences.txt -no-sos -no-eos -order ORDER -lm model.arpa -cdiscount 0
    
    or
    
    ngram-count -text sentences.txt -no-sos -no-eos -order ORDER -lm model.arpa -gt1max 0 -gt2max 0 -gt3max 0 -gt4max 0 -gt5max 0 -gt6max 0 -gt7max 0 -gt8max 0 -gt9max 0 -gtmax 0

## Resources
* [FAQ](http://www.speech.sri.com/projects/srilm/manpages/srilm-faq.7.html)

