# NLTK
* seems not to be able to create LM automatically


## Native usage
NLTK is used via Python code, using the "nltk" package.

### Load own corpus

    from nltk.corpus import PlaintextCorpusReader
    corpus_root = '/usr/share/dict'
    wordlists = PlaintextCorpusReader(corpus_root, '.*')

