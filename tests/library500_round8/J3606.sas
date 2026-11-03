/* J3606 reg_quadratic_coefficient, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3606a; do x=1 to 7+3; x2=x*x; y=5+2*x+3*x2; output; end; run;
proc reg data=j3606a outest=j3606b noprint; model y=x x2; run; quit;
data j3606o; set j3606b; actual=x2; run;

data _null_; if 0 then set j3606o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3606 rows=' rows;
else do; set j3606o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3606';
else put 'ERROR: ROUND8_FAIL=J3606 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3606:; quit;
