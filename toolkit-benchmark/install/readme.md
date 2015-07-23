# Overview
1. [JavaAPI]
2. unified language model API (ULMA) bash scripts
2.1 [central entry point to start any ULMA instance]
2.2 one ULMA bash script per language model/toolkit
3. language model/toolkit specific API (binaries, Python module aso.)

## Language models/toolkits ULMA compatibility
| Name | MLE | KN backoff | KN interpolated | MKN |
| ---- | --- | ---------- | --------------- | --- |
| [DALM](https://github.com/jnory/DALM)
 | ? | ? | ? | ? |
| [GLMTK](https://github.com/renepickhardt/generalized-language-modeling-toolkit)
 | ? | ? | ? | ? |
| [KenLM](http://kheafield.com/code/kenlm/)
 | no | ? | ? | ? |
| [Kylm](http://www.phontron.com/kylm/)
 | sos/eos only rdy | ? | ? | ? |
| [NLTK](https://github.com/nltk/nltk)
 | unclear | ? | ? | ? |
| [OpenGRM](http://opengrm.org/)
 | ? | ? | ? | ? |
| [SRILM](http://www.speech.sri.com/projects/srilm/)
 | both rdy | ? | ? | ? |

We separate support for sos/eos enabled and disabled for each estimator.

