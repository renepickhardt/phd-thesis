# Overview
1. [JavaAPI]
2. unified language model API (ULMA) bash scripts
2.1 [central entry point to start any ULMA instance]
2.2 one ULMA bash script per language model/toolkit
3. language model/toolkit specific API (binaries, Python module aso.)

## Supported language models/toolkits
| Name | Usage | Installer | ULMA |
| ---- | ---------- | --------- | ---- |
| [DALM](https://github.com/jnory/DALM) | binaries, C++ | yes | no |
| [GLMTK](https://github.com/renepickhardt/generalized-language-modeling-toolkit) | ? | ? | no |
| [KenLM](http://kheafield.com/code/kenlm/) | binaries, Python | yes | no |
| [Kylm](http://www.phontron.com/kylm/) | Java (JAR) | yes | no |
| [NLTK](https://github.com/nltk/nltk) | Python | yes | no |
| [OpenGRM](http://opengrm.org/) | binaries | yes | no |
| [SRILM](http://www.speech.sri.com/projects/srilm/) | binaries| yes | no |

### Stumbled across
* (pattern)[http://www.clips.ua.ac.be/pages/pattern]
* (scikits.learn)[http://scikit-learn.sourceforge.net/stable/]
* (fuzzywuzzy)[https://github.com/seatgeek/fuzzywuzzy]
* OxLM
* NPLM

## Next steps
* Maximum-Likelihood-Model w/o smoothing abc-corpus (glmtk res), correct ARPA output
* Kylm/KenLM: try w/o end-of-sentence

## Issues
* SRILM: can not find libfst.so

## LM internal errors
### Kylm/KenLM w e-o-s
* Markoff: P(try|w1 w2 w3 w4) ~ P(try|w3 w4) (with P1 > P2!)
* P(w1) instead of P(w1 _ _ _)

