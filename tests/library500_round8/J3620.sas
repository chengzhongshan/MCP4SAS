/* J3620 reg_noint_slope, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3620a; do x=1 to 11; y=3*x; output; end; run;
proc reg data=j3620a outest=j3620b noprint; model y=x / noint; run; quit;
data j3620o; set j3620b; actual=x; run;

data _null_; if 0 then set j3620o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3620 rows=' rows;
else do; set j3620o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3620';
else put 'ERROR: ROUND8_FAIL=J3620 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3620:; quit;
