/* J3615 reg_noint_slope, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3615a; do x=1 to 6; y=3*x; output; end; run;
proc reg data=j3615a outest=j3615b noprint; model y=x / noint; run; quit;
data j3615o; set j3615b; actual=x; run;

data _null_; if 0 then set j3615o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3615 rows=' rows;
else do; set j3615o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3615';
else put 'ERROR: ROUND8_FAIL=J3615 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3615:; quit;
