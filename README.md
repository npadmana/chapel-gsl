Implemented
===========

Currently implemented :
* Special Functions
* Random Number Generation
* Random Number Distributions
* 1D interpolation
* Integration


Known Issues
============

GSL is a big package, and there are likely issues lurking 
in the large parts of the code that aren't tested. Please 
file issues for any problems that arise.

* We currently are using the master branch of Chapel to get 
the integration routines working (required to recast void pointers).
These should start to work again with Chapel 1.13. (#1)

Versions
========

This code requires Chapel built with LLVM support. 

The code uses the system GSL headers, except when described
below. We aim to test this code out using GSL 1.16 and GSL 2.1. 

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
required some changes to be useable in Chapel. 
In all cases, the 
original file is also saved, to enable comparisons.

