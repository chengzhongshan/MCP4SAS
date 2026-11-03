/* J3629 reg_perfect_fit_rsquare, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3629a; do x=1 to 10+2; y=7+4*x; output; end; run;
proc reg data=j3629a outest=j3629b rsquare noprint; model y=x; run; quit;
data j3629o; set j3629b; actual=_rsq_; run;

data _null_; if 0 then set j3629o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3629 rows=' rows;
else do; set j3629o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3629';
else put 'ERROR: ROUND8_FAIL=J3629 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3629:; quit;
