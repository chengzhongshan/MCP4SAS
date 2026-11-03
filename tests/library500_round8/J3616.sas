/* J3616 reg_noint_slope, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3616a; do x=1 to 7; y=3*x; output; end; run;
proc reg data=j3616a outest=j3616b noprint; model y=x / noint; run; quit;
data j3616o; set j3616b; actual=x; run;

data _null_; if 0 then set j3616o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3616 rows=' rows;
else do; set j3616o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3616';
else put 'ERROR: ROUND8_FAIL=J3616 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3616:; quit;
