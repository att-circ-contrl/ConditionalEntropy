# Conditional Entropy Library

## Overview

This library provides functions for computing Shannon entropy, conditional
Shannon entropy, mututal information, and (approximate) transfer entropy
of continuous-valued data and of discrete-valued data (event counts).

FIXME - Still need to add the following:
* Partial information decomposition.
* Bootstrapping-based statistics (and maybe jackknife-based for faster but
less accurate).
* Granger causality (TE reduces to this for normal random variables).
* Pearson's correlation (MI interconverts with this for zero-mean normal
random variables).

## Folders

* `library` -- Matlab library function code.
* `manual` -- Project documentation PDFs.
* `manual-src` -- LaTeX files for rebuilding project documentation.
* `sample-code` -- Example code that uses this library.
* `testing` -- Test scripts used during development. The sample code is a
cleaned-up subset of this.

## References

* C. E. Shannon, _A Mathematical Theory of Communication_,
The Bell System Technical Journal,
v 27, pp 379-423,623-656, July, October 1948
* A. Treves, S. Panzeri, _The Upward Bias in Measures of Information
Derived from Limited Data Samples_,
Neural Computation, v 7, pp 399-407, 1995
* S. P. Strong, R. Koberle, R. R de Ruyter van Stevenick, W Bailek,
_Entropy and Information in Neural Spike Trains_,
Physical Review Letters, v 80, no 1, pp 197-200, January 1998
* A. Palmigiano, T. Geisel, F. Wolf, D. Battaglia,
_Flexible Information Routing by Transient Synchrony_,
Nature Neuroscience, v 20, no 7, pp 1014-1022, 2017

_(This is the end of the file.)_
