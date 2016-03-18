Versions
========

This code requires Chapel built with LLVM support. 

The code uses the system GSL headers, except when described
below. We aim to test this code out using GSL 1.15 and GSL 2.1. 

Documentation
=============

We recommend the GSL manual for detailed documentation. We provide
a simple howto.chpl file that does some simple tests and shows how 
things work. This isn't expected to be an extensive test suite though.

Building this assumes that the environment variable GSL_DIR is set. 
If you did a normal install, this should be /usr/local/


Replacement headers
===================

Some of the GSL headers did not parse immediately, and 
required some changes to be useable in Chapel. These are
listed below, with the required changes. In all cases, the 
original file is also saved, to enable comparisons.

* gsl_rng.h : 
  The gsl_rng_type and gsl_rng structs were running into issues
  while being parsed. Made them simple opaque structures, from the 
  Chapel perspective. 

  This used a typedef struct which wasn't correctly
  parsed. Splitting it into a struct and a typedef solved this issue.

