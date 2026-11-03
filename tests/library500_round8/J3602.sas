/* J3602 reg_quadratic_coefficient, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3602a; do x=1 to 3+3; x2=x*x; y=5+2*x+3*x2; output; end; run;
proc reg data=j3602a outest=j3602b noprint; model y=x x2; run; quit;
data j3602o; set j3602b; actual=x2; run;

data _null_; if 0 then set j3602o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3602 rows=' rows;
else do; set j3602o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3602';
else put 'ERROR: ROUND8_FAIL=J3602 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3602:; quit;
