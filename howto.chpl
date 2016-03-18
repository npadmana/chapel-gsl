use GSL;
use GSL.SpecFun;
use GSL.Random;
use SysCTypes;

var res : gsl_sf_result;
writeln(gsl_sf_erf(0.1));
var ret = gsl_sf_erf_e(0.1, c_ptrTo(res));
writeln(res);
writeln(toString(gsl_strerror(ret)));

ret = gsl_sf_airy_Ai_e(10.0, GSL_PREC_DOUBLE : c_uint, c_ptrTo(res));
writeln(toString(gsl_strerror(ret)), res);
ret = gsl_sf_airy_Ai_e(10.0, GSL_PREC_APPROX : c_uint,c_ptrTo(res));
writeln(toString(gsl_strerror(ret)), res);

var rng = gsl_rng_alloc(gsl_rng_mt19937);
for ii in 1..10 {
  writeln(gsl_rng_uniform(rng));
}
gsl_rng_free(rng);
