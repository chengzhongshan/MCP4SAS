/* J3614 reg_noint_slope, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3614a; do x=1 to 5; y=3*x; output; end; run;
proc reg data=j3614a outest=j3614b noprint; model y=x / noint; run; quit;
data j3614o; set j3614b; actual=x; run;

data _null_; if 0 then set j3614o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3614 rows=' rows;
else do; set j3614o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3614';
else put 'ERROR: ROUND8_FAIL=J3614 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3614:; quit;
