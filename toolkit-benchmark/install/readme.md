# Overview
1. [JavaAPI]
2. unified language model API (ULMA) bash scripts
2.1 [central entry point to start any ULMA instance]
2.2 one ULMA bash script per language model/toolkit
3. language model/toolkit specific API (binaries, Python module aso.)

## Language models/toolkits ULMA compatibility
| Name | MLE (no-sos/eos) |
| ---- | -------------------- |
| [DALM](https://github.com/jnory/DALM)
 | ? |
| [GLMTK](https://github.com/renepickhardt/generalized-language-modeling-toolkit)
 | ? |
| [KenLM](http://kheafield.com/code/kenlm/)
 | no |
| [Kylm](http://www.phontron.com/kylm/)
 | no-sos/eos is unclear |
| [NLTK](https://github.com/nltk/nltk)
 | unclear |
| [OpenGRM](http://opengrm.org/)
 | ? |
| [RandLM](http://randlm.sourceforge.net/)
 | ? |
| [SRILM](http://www.speech.sri.com/projects/srilm/)
 | apparently |

## Notes
### SRILM

SRILM can fix ARPA files via `ngram -order N -lm input -write-lm output`.

* `ngram-count -text sentences.txt -no-sos -no-eos -order ORDER -lm model.arpa -gt1max 0 -gt2max 0 -gt3max 0 -gt4max 0 -gt5max 0 -gt6max 0 -gt7max 0 -gt8max 0 -gt9max 0 -gtmax 0`
-> uses sos/eos & Good Turing discounting/smoothing by default

### KenLM
"KenLM estimates unpruned language models with modified Kneser-Ney smoothing."
That's it.

KenLM can verify ARPA files.

* create ARPA: `bin/lmplz -o ORDER -S MEMORY -T /tmp < text > model.arpa`

### Kylm
Kylm supports a number of smoothing methods.

Kylm can calculate the cross entropy of a corpus using one or more language models.

* create ARPA: `java -cp kylm.jar kylm.main.CountNgrams training.txt model.arpa -n ORDER`
* supports MLE `-ml`, Kneser Ney: `-kn`, Modified Kneser Ney: `-mkn`
* start/end of sentence symbols can be changed, maybe to `null`, but is this sufficient?
 * `-startsym SYMBOL`
 * `-termsym SYMBOL`

### NLTK

Maybe we need this [trainer](https://github.com/japerk/nltk-trainer) to analyze corpses?

#### 

* use `ProbDist.samples()` returns all samples with non-zero prob., use `.prop(sample)` to get samples's prob.
* supports MLE `nltk.probability.MLEProbDist`

### OpenGRM

### RandLM
Creates randomized language models only. (BackoffRandLM vs CountRandLM)

* Hadoop
** read corpus via Hadoop
** count ngrams with Hadoop
** upload counts to OS filesystem
* or from ARPA file
* ./buildlm -input-type counts -input-path PATH -smoothing X -order ORDER -struct LogFreqBloomFilter

or

* ./buildlm -input-type corpus -input-path PATH -smoothing X -order ORDER -struct LogFreqBloomFilter

or

./buildlm -struct BloomMap -falsepos 8 -values 8 -output-prefix model -order ORDER < corpus
