use GSL;

{
  // Special functions 
  // We try out both interfaces. Note that you need to explicitly
  // use the c_ptrTo function in these cases.
  use SpecFun;
  var res : gsl_sf_result;
  writeln(gsl_sf_erf(0.1));
  // Note how the res structure is available to the user
  var ret = gsl_sf_erf_e(0.1, c_ptrTo(res));
  writeln(res);
  writeln(new string(gsl_strerror(ret)));


  // Use GSL precision modes. These are #defines and the extern block code
  // gets the types wrong, so we need to explicitly case.
  ret = gsl_sf_airy_Ai_e(10.0, GSL_PREC_DOUBLE : c_uint, c_ptrTo(res));
  writeln(new string(gsl_strerror(ret)), res);
  ret = gsl_sf_airy_Ai_e(10.0, GSL_PREC_APPROX : c_uint,c_ptrTo(res));
  writeln(new string(gsl_strerror(ret)), res);
}

{
  use RandomGSL;
  // Random number generators
  var rng1 = new Random(RNGType.MT19937);
  var rng2 = new Random(RNGType.Taus2);
  writeln("Random numbers from a few random number generators");
  for ii in 1..10 {
    writeln(rng1.uniform(),' ',rng2.get());
  }
  
  // Try out some random number distributions
  var gauss = new Gaussian(1.0, rng1);
  var arr : [0.. #1000]real(64);
  // GSL random number routines may share state. Use a serial loop
  for x in arr do x = gauss.get();
  writeln("<x> of a sample of Gaussian random numbers :",(+ reduce arr)/1000.0);
  writeln("<x^2> of a sample of Gaussian random numbers :",(+ reduce arr**2)/1000.0);
  writeln("<x^3> of a sample of Gaussian random numbers :",(+ reduce arr**3)/1000.0);
  writeln("<x^4> of a sample of Gaussian random numbers :",(+ reduce arr**4)/1000.0);

  // Try the CDF
  writeln("68.3% of a Gaussian distribution occurs < ",gauss.CDF(CDFType.Pinv,0.683));
  writeln("Expected : 0.476104 (Mathematica)");

  // Try some Poisson numbers
  var pois = new Poisson(2, gauss.rng); 
  writeln("Some Poisson numbers with mean 2...");
  for ii in 1..50 do writef("%s ",pois.get());
  writeln();

  delete rng1; 
  delete rng2;
  delete pois;
  delete gauss;
}

{
  // 1D interpolation
  use Interp1D.C;

  // Set up a simple function
  var x : [0.. #10] real(64);
  [i in x.domain] x[i]=i*0.1;
  var y : [0.. #10] real(64) = x**3 + 2*x;
  writeln('x:',x);
  writeln('y:',y);

  // Use the 1D higher level interface for this
  var sp = gsl_spline_alloc(gsl_interp_cspline, 10);
  var acc = gsl_interp_accel_alloc();
  gsl_spline_init(sp, c_ptrTo(x[0]), c_ptrTo(y[0]), 10);
  writeln('x^3 + 2x for x=0.45 :',gsl_spline_eval(sp, 0.45, acc));
  writeln('Compared to :',0.45**3+0.9);
  gsl_interp_accel_free(acc);
  gsl_spline_free(sp);
}

{
  // 1D Interpolation, use the Chapel interface
  use Interp1D;
  // Set up a simple function
  var x : [0.. #10] real(64);
  [i in x.domain] x[i]=i*0.1;
  var y : [0.. #10] real(64) = x**3 + 2*x;
  var sp = new Spline(x,y,SplineType.CUBIC);
  writeln('x^3 + 2x for x=0.45 (Chapel version) :',sp.eval(0.45));
  delete sp;
}



{
  // Integration
  use Integration;
  // The following is the example in the GSL manual translated.
  // We do the following integral :
  //    \int_0^1 x^{-1/2} log(x) dx = -4
  // 
  // Note that, for this particular problem, it might have been
  // simpler to just wrap everything in C. Also note that we need to 
  // write some boilerplate to actually pass things to C.
  record Payload {
    var alpha : real;
  }
  export proc func(x : real, p : c_void_ptr) : real {
    var r = (p : c_ptr(Payload)).deref();
    return log(r.alpha*x)/sqrt(x);
  }
  extern {
    #include <chpl_gsl/gsl_integration.h>

    double func(double,void*);
    void call_qags(void* params, double a, double b, double epsabs, double epsrel, size_t limit, 
        gsl_integration_workspace* wk, double *result, double *err) 
    {
      gsl_function F;
      F.function = &func;
      F.params = params;
      gsl_integration_qags(&F, a,b,epsabs,epsrel,limit,wk,result,err);
    }
  }
  var wk = gsl_integration_workspace_alloc(1000);
  var result, error: real(64);
  var p = new Payload(1.0);
  call_qags(c_ptrTo(p):c_void_ptr, 0, 1, 0, 1.e-07,1000,wk,c_ptrTo(result), c_ptrTo(error));
  const expected = -4.0;
  writeln("Integration result : ",result);
  writeln("Expected : ", expected);
  writeln("Estimated error : ",error);
  writeln("Actual error : ",abs(result-expected));
  gsl_integration_workspace_free(wk);
}

{
  // Constants 
  use Constants;
  writef("The speed of light in m/s is %r\n",GSL_CONST_MKS_SPEED_OF_LIGHT);
}
