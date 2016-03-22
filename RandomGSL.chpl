/* A Chapel-esque wrapper for the GSL random number routines.

The C routines are fully exposed, but hidden inside a "C" nested module. 
 */

module RandomGSL {

  use C_RandomGSL;

  enum RNGType {
    MT19937, Taus2
  };
  
  enum CDFType {
    P,Q,Pinv,Qinv
  };

  class Random {
    var rng : c_ptr(gsl_rng);
    var lock$ : sync bool;

    proc seed(s : uint(64)) {
      gsl_rng_set(rng, s);
    }

    proc Random(rngtype : RNGType, s : uint(64)=0) {
      select rngtype {
        when RNGType.MT19937 do rng=gsl_rng_alloc(gsl_rng_mt19937);
        when RNGType.Taus2 do rng=gsl_rng_alloc(gsl_rng_taus2);
        otherwise halt("Unimplemented RNG type");
      }
      if s != 0 {
        seed(s);
      }
    }
    
    proc Random(r : Random) {
      rng = gsl_rng_clone(r.rng);
    }

    proc ~Random() {
      gsl_rng_free(rng);
    }

    proc get(nmax : uint(64)=0) : uint(64) {
      var ret : uint(64);
      lock$=true;
      if nmax > 0 {
        ret = gsl_rng_uniform_int(rng, nmax);
      } else {
        ret = gsl_rng_get(rng);
      }
      lock$;
      return ret;
    }

    proc uniform(pos : bool = false) : real(64) {
      var ret : real(64);
      lock$=true;
      if pos {
        ret = gsl_rng_uniform_pos(rng);
      } else {
        ret = gsl_rng_uniform(rng);
      }
      lock$;
      return ret;
    }
  }
  

  /* Gaussian Random Variates */
  class Gaussian {
    type ValType = real(64);
    var rng : Random;
    var sigma : real(64);
    var lock$ : sync bool;

    proc Gaussian(s : real(64) = 1, rngtype : RNGType = RNGType.MT19937, 
        seed : uint(64) = 0) {
      sigma = s;
      rng = new Random(rngtype, seed);
    }

    proc Gaussian(s : real(64) = 1, rng1 : Random) {
      sigma = s;
      rng = new Random(rng1);
    }
    
    proc get() : ValType {
      var ret : ValType;
      lock$=true;
      ret = gsl_ran_gaussian(rng.rng,sigma);
      lock$;
      return ret;
    }

    proc PDF(x : ValType) {
      return gsl_pdf_gaussian(x, sigma);
    }
    
    proc CDF(p : CDFType, x: ValType) {
      select p {
        when CDFType.P do return gsl_cdf_gaussian_P(x, sigma);
        when CDFType.Q do return gsl_cdf_gaussian_Q(x, sigma);
        when CDFType.Pinv do return gsl_cdf_gaussian_Pinv(x, sigma);
        when CDFType.Qinv do return gsl_cdf_gaussian_Qinv(x, sigma);
        otherwise halt();
      }
    }
  }


  /* Poisson Random Variates */
  class Poisson {
    type ValType = uint(32);
    var rng : Random;
    var mu : real(64);
    var lock$ : sync bool;

    proc Poisson(s : real(64), rngtype : RNGType = RNGType.MT19937, 
        seed : uint(64) = 0) {
      mu = s;
      rng = new Random(rngtype, seed);
    }

    proc Poisson(s : real(64), rng1 : Random) {
      mu = s;
      rng = new Random(rng1);
    }
    
    proc get() : ValType {
      var ret : ValType;
      lock$=true;
      ret = gsl_ran_poisson(rng.rng,mu);
      lock$;
      return ret;
    }

    proc PDF(x : ValType) {
      return gsl_pdf_poisson(x, mu);
    }
    
    proc CDF(p : CDFType, x: ValType) {
      select p {
        when CDFType.P do return gsl_cdf_poisson_P(x, mu);
        when CDFType.Q do return gsl_cdf_poisson_Q(x, mu);
        otherwise halt("Unimplemented CDF type for Poisson");
      }
    }
  }



  module C_RandomGSL {
    extern {
      #include "chpl_gsl/gsl_rng.h"
      #include "chpl_gsl/gsl_randist.h"
      #include "gsl/gsl_cdf.h"
    }
  }
}

