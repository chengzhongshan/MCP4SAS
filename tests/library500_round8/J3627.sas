/* J3627 reg_perfect_fit_rsquare, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3627a; do x=1 to 8+2; y=7+4*x; output; end; run;
proc reg data=j3627a outest=j3627b rsquare noprint; model y=x; run; quit;
data j3627o; set j3627b; actual=_rsq_; run;

data _null_; if 0 then set j3627o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3627 rows=' rows;
else do; set j3627o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3627';
else put 'ERROR: ROUND8_FAIL=J3627 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3627:; quit;
