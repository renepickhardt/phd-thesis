# Kylm
Kylm can "smooth" language models using
* maximum likelihood `-ml`,
* Good-Turing `-gt`,
* Witten-Bell `-wb`,
* absolute smoothing `-abs`,
* Kneser-Ney `-kn` and
* modified Kneser-Ney `-mkn`.

It can calculate cross-entropies of a corpus using one or more language models.

## Native Usage
### Export smoothed language model to ARPA file

    java -cp kylm.jar kylm.main.CountNgrams sentences.txt model.arpa -n ORDER -MODEL

### Export unsmoothed language model to ARPA file
Start/end of sentence symbols can be changed, maybe to `null`, but unclear if sufficient!

Smoothing of unigrams can be disabled, but it can't be disabled globally.
* `-startsym SYMBOL`
* `-termsym SYMBOL`

### Resources
#### kylm.main.CountNgrams --help

    Example: java -cp kylm.jar kylm.main.CountNgrams training.txt model.arpa

    N-gram model options
        -n:         the length of the n-gram context [default: 3]
        -trim:      the trimming for each level of the n-gram (example: 0:1:1)
        -name:      the name of the model
        -smoothuni: whether or not to smooth unigrams

    Symbol/Vocabulary options
        -vocab:     the vocabulary file to use
        -startsym:  the symbol to use for sentence starts [default: <s>]
        -termsym:   the terminal symbol for sentences [default: </s>]
        -vocabout:  the vocabulary file to write out to
        -ukcutoff:  the cut-off for unknown words [default: 0]
        -uksym:     the symbol to use for unknown words [default: <unk>]
        -ukexpand:  expand unknown symbols in the vocabulary
        -ukmodel:   model unknown words. Arguments are processed first to last, 
                    so the most general model should be specified last. 
                    Format: "symbol:vocabsize[:regex(.*)][:order(2)][:smoothing(wb)]"

    Class options
        -classes:   a file containing word class definitions 
                    ("class word [prob]", one per line)

    Smoothing options [default: kn]
        -ml:        maximum likelihood smoothing
        -gt:        Good-Turing smoothing (Katz Backoff)
        -wb:        Witten-Bell smoothing
        -abs:       absolute smoothing
        -kn:        Kneser-Ney smoothing (default)
        -mkn:       Modified Kneser-Ney smoothing (of Chen & Goodman)

    Output options [default: arpa]
        -bin:       output in binary format
        -wfst:      output in weighted finite state transducer format (WFST)
        -arpa:      output in ARPA format
        -neginf:    the number to print for non-existent backoffs (default: null, example: -99)

    Miscellaneous options
        -debug:     the level of debugging information to print [default: 0]

