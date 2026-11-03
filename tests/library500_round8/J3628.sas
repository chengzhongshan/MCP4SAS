/* J3628 reg_perfect_fit_rsquare, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3628a; do x=1 to 9+2; y=7+4*x; output; end; run;
proc reg data=j3628a outest=j3628b rsquare noprint; model y=x; run; quit;
data j3628o; set j3628b; actual=_rsq_; run;

data _null_; if 0 then set j3628o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3628 rows=' rows;
else do; set j3628o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3628';
else put 'ERROR: ROUND8_FAIL=J3628 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3628:; quit;
