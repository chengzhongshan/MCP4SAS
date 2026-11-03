/* J3630 reg_perfect_fit_rsquare, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3630a; do x=1 to 11+2; y=7+4*x; output; end; run;
proc reg data=j3630a outest=j3630b rsquare noprint; model y=x; run; quit;
data j3630o; set j3630b; actual=_rsq_; run;

data _null_; if 0 then set j3630o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3630 rows=' rows;
else do; set j3630o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3630';
else put 'ERROR: ROUND8_FAIL=J3630 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3630:; quit;
