/* J3611 reg_noint_slope, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3611a; do x=1 to 2; y=3*x; output; end; run;
proc reg data=j3611a outest=j3611b noprint; model y=x / noint; run; quit;
data j3611o; set j3611b; actual=x; run;

data _null_; if 0 then set j3611o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3611 rows=' rows;
else do; set j3611o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3611';
else put 'ERROR: ROUND8_FAIL=J3611 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3611:; quit;
