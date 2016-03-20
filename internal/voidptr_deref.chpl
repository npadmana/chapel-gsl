use SysCTypes;

record R { 
  var alpha : real;
}

export proc integrand(x : real, ptr : c_void_ptr) : real {
  // THE LINE BELOW DOESN'T WORK
  var p = ptr : c_ptr(R); // How do I get this, or equivalent to work
  var r = p.deref();
  writeln(r);
  return r.alpha*x;
}

extern {
  double integrand(double, void*);
  static  void integrate(void *p) {
    // A real integrator would do more
    double y;
    y = integrand(1,p);
  }
}

var r1 = new R(1.0);
writeln(r1);
var p1 = c_ptrTo(r1);
integrate(p1:c_void_ptr);
