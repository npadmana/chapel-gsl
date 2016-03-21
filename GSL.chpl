// This is a simple wrapper around the extern block functionality.
// 
module GSL {
  use SysCTypes;
  require '-lgsl','-lgslcblas';

  // Random number generation
  // Random distributions
  module Random {
    extern {
      #include "chpl_gsl/gsl_rng.h"
      #include "chpl_gsl/gsl_randist.h"
      #include "gsl/gsl_cdf.h"
    }
  }

  // Special Functions
  module SpecFun {
    extern {  
      #include "gsl/gsl_sf.h"
    }
  }
  
  // 1D Interpolation
  module Interp1D {
    extern {
      #include "chpl_gsl/gsl_interp.h"
      #include "chpl_gsl/gsl_spline.h"
    }
  }

  // Integration
  module Integration {
    extern {
      #include "chpl_gsl/gsl_integration.h"
    }
  }

  // Constants
  module Constants {
    extern {
      #include "gsl/gsl_const.h"
    }
  }

}
