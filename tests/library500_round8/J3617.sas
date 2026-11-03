/* J3617 reg_noint_slope, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3617a; do x=1 to 8; y=3*x; output; end; run;
proc reg data=j3617a outest=j3617b noprint; model y=x / noint; run; quit;
data j3617o; set j3617b; actual=x; run;

data _null_; if 0 then set j3617o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3617 rows=' rows;
else do; set j3617o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3617';
else put 'ERROR: ROUND8_FAIL=J3617 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3617:; quit;
