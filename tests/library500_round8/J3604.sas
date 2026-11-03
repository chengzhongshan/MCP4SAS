/* J3604 reg_quadratic_coefficient, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3604a; do x=1 to 5+3; x2=x*x; y=5+2*x+3*x2; output; end; run;
proc reg data=j3604a outest=j3604b noprint; model y=x x2; run; quit;
data j3604o; set j3604b; actual=x2; run;

data _null_; if 0 then set j3604o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3604 rows=' rows;
else do; set j3604o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3604';
else put 'ERROR: ROUND8_FAIL=J3604 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3604:; quit;
