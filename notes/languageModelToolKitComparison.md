The main goal is to provide a simple check of correctness and to understand how probabilities in the various language modelling toolkits are handled.

we will provide the following test: 
Corpus = {a}
Corpus = {{a a b c a b},{b a c a b a},{a b c a a b}}

## toolkits for testing
so far it seems like we will be testing 9 frameworks about the correctness of implementing smoothing methods. 

* nltk
* kylm
* SRIlm
* glmtk
* openngrm
* IRST
* Randlm
* kenLM
* DALM

## dimensions to check
* do probabilities sum up to one?
* n
* what about unk token?
* how are start of sentence and end of sentence tags handled