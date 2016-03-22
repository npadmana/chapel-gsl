/* A Chapel-esque wrapper for the GSL interpolation and spline routines.

The C routines are fully exposed, but hidden inside a "C" nested module. 
 */

module Interp1D {

  use C;

  /* Types of splines exposed */
  enum SplineType {
    LINEAR, CUBIC
  };
  
  /* A simple Spline class, wrapping the GSL routines 

  The eval method is protected by a lock, and so will be slower
   to exavluate, while eval$ doesn't do that check.
   */
  class Spline {
    var nx : uint(64);
    var sp : c_ptr(gsl_spline);
    var acc : c_ptr(gsl_interp_accel);
    var dom : domain(1);
    var xsave, ysave : [dom]real(64);
    var sptype : SplineType;
    var lock$ : sync bool;
  
    /* Internal initialization */
    proc init() {
      // Allocate the spline
      // This switch here avoids warnings from passing GSL defined types around.
      select sptype {
        when SplineType.LINEAR do sp = gsl_spline_alloc(gsl_interp_linear, nx);
        when SplineType.CUBIC do sp = gsl_spline_alloc(gsl_interp_cspline, nx);
        otherwise halt("Unknown spline type");
      }
      acc = gsl_interp_accel_alloc();
      gsl_spline_init(sp, c_ptrTo(xsave[0]), c_ptrTo(ysave[0]), nx);
    }


    /* Basic constructor */
    proc Spline(x:[?Dx]real(64),y:[?Dy]real(64), tt : SplineType) {
      if (Dx.rank != 1) && (Dy.rank != 1) {
        halt("x and y need to be rank 1");
      }
      nx = Dx.size : uint(64);
      if (nx != Dy.size) {
        halt("x and y need to have the same size");
      }

      // Cache the data
      sptype = tt;
      dom = {0.. #nx};
      xsave = x;
      ysave = y;

      init();
    }

    /* Copy constructor */
    proc Spline(sp : Spline) {
      sptype = sp.sptype;
      nx = sp.dom.size;
      dom = {0.. #nx};
      xsave = sp.xsave;
      ysave = sp.ysave;

      init();
    }


    /* Evaluate, using locks, so can be safely used inside a parallel loop,
    although you likely won't see a speed-up
    */
    proc eval$(x:real(64)) : real(64) {
      var ret : real(64);
      lock$ = true;
      ret = gsl_spline_eval(sp, x, acc);
      lock$;
      return ret;
    }

    /* Evaluate. */
    proc eval(x:real(64)) : real(64) {
      return gsl_spline_eval(sp, x, acc);
    }
  
    /* Destructor */
    proc ~Spline() {
      gsl_spline_free(sp);
      gsl_interp_accel_free(acc);
    }
  }


  module C {
    extern {
      #include "chpl_gsl/gsl_interp.h"
      #include "chpl_gsl/gsl_spline.h"
    }
  }
}

