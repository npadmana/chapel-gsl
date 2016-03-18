// This is a simple wrapper around the extern block functionality.
// 
module GSL {
  use SysCTypes;
  require '-lgsl','-lgslcblas';

  module Random {
    extern {
       #include "chpl_gsl/gsl_rng.h"
    }
  }

  module SpecFun {
    extern {  
      #include "gsl/gsl_sf.h"
    }
  }

}
