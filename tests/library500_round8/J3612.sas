/* J3612 reg_noint_slope, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3612a; do x=1 to 3; y=3*x; output; end; run;
proc reg data=j3612a outest=j3612b noprint; model y=x / noint; run; quit;
data j3612o; set j3612b; actual=x; run;

data _null_; if 0 then set j3612o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3612 rows=' rows;
else do; set j3612o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3612';
else put 'ERROR: ROUND8_FAIL=J3612 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3612:; quit;
