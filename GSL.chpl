// This is a simple wrapper around the extern block functionality.
// 
module GSL {
  use SysCTypes;
  require '-lgsl','-lgslcblas';

  module Random {
    extern {
      #include "chpl_gsl/gsl_rng.h"
      #include "chpl_gsl/gsl_randist.h"
      #include "gsl/gsl_cdf.h"
    }
  }

  module RanDist {
    extern {
    }
  }

  module SpecFun {
    extern {  
      #include "gsl/gsl_sf.h"
    }
  }

}
