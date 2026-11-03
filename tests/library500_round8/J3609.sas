/* J3609 reg_quadratic_coefficient, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3609a; do x=1 to 10+3; x2=x*x; y=5+2*x+3*x2; output; end; run;
proc reg data=j3609a outest=j3609b noprint; model y=x x2; run; quit;
data j3609o; set j3609b; actual=x2; run;

data _null_; if 0 then set j3609o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3609 rows=' rows;
else do; set j3609o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3609';
else put 'ERROR: ROUND8_FAIL=J3609 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3609:; quit;
