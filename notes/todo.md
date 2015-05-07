## be able to reconstruct the following
* good turing estimate
* backof models
* interpol models
* clustered models
* absolut discounting models

## reformulate the smoothing problem
* goal is to find a good covering of the probability space in the training data such that a probability function that has non zero propabilities can be estimated.

## Kneser ney paper
* Reformulate 1995 kneser ney paper in a mathematical sound way
* see how big the mistakes are when normalizing the denominator of formula 8 or 9
* how to calculate \beta_1 for a trigram model (second backof step?)
* make sure continuation counts are correct when backing of one step does not work (take the cont bigram for example. this is part of staying mathematically sound)
* understand the marginal constraint and where it comes from
* understand the proof in appendix 1 of goodman 2001 technical report stating that the marginal constrain has to hold

## shannon paper
* be able to understand where entropy comes from
* be able to put in into relation with a next word prediction measure (shannon already does these things)

## questioning chen good man
* don't believe that interpol methods in general work better than back of methods

## reformulate the generalized language model
* it is just a generalized backoff (similar to kirchhoff)
* make this as working on the same probability function all the time (well one could backoff)

## be more sound in probability theory
* learn baysian networks
* learn about log likelihood methods
* be more familiar with: chainrule, random variables, marginals, joint distributions, choosing a prior

## learn sphinx
* we have to see how different language models have effects on word error rates
* we have to see how NKSS correlate to WER
* we have to see how Entropy correlates to WER

## finnish GLMTK
* see the git repo and todo list
