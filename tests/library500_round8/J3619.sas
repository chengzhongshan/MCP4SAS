/* J3619 reg_noint_slope, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3619a; do x=1 to 10; y=3*x; output; end; run;
proc reg data=j3619a outest=j3619b noprint; model y=x / noint; run; quit;
data j3619o; set j3619b; actual=x; run;

data _null_; if 0 then set j3619o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3619 rows=' rows;
else do; set j3619o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3619';
else put 'ERROR: ROUND8_FAIL=J3619 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3619:; quit;
