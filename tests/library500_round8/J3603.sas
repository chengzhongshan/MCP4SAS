/* J3603 reg_quadratic_coefficient, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3603a; do x=1 to 4+3; x2=x*x; y=5+2*x+3*x2; output; end; run;
proc reg data=j3603a outest=j3603b noprint; model y=x x2; run; quit;
data j3603o; set j3603b; actual=x2; run;

data _null_; if 0 then set j3603o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3603 rows=' rows;
else do; set j3603o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3603';
else put 'ERROR: ROUND8_FAIL=J3603 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3603:; quit;
