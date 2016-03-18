use GSL;

{
  // Special functions 
  // We try out both interfaces. Note that you need to explicitly
  // use the c_ptrTo function in these cases.
  use GSL.SpecFun;
  var res : gsl_sf_result;
  writeln(gsl_sf_erf(0.1));
  var ret = gsl_sf_erf_e(0.1, c_ptrTo(res));
  writeln(res);
  writeln(toString(gsl_strerror(ret)));


  // Use GSL precision modes. These are #defines and the extern block code
  // gets the types wrong, so we need to explicitly case.
  ret = gsl_sf_airy_Ai_e(10.0, GSL_PREC_DOUBLE : c_uint, c_ptrTo(res));
  writeln(toString(gsl_strerror(ret)), res);
  ret = gsl_sf_airy_Ai_e(10.0, GSL_PREC_APPROX : c_uint,c_ptrTo(res));
  writeln(toString(gsl_strerror(ret)), res);
}

{
  use GSL.Random;
  // Random number generators
  // Note that this follows the C-API --- so you need to explicitly free things.
  var rng1 = gsl_rng_alloc(gsl_rng_mt19937);
  var rng2 = gsl_rng_alloc(gsl_rng_taus2);
  writeln("Random numbers from a few random number generators");
  for ii in 1..10 {
    writeln(gsl_rng_uniform(rng1), ' ',gsl_rng_get(rng2));
  }
  gsl_rng_free(rng1);
  gsl_rng_free(rng2);
}
