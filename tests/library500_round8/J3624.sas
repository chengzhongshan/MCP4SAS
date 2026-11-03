/* J3624 reg_perfect_fit_rsquare, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3624a; do x=1 to 5+2; y=7+4*x; output; end; run;
proc reg data=j3624a outest=j3624b rsquare noprint; model y=x; run; quit;
data j3624o; set j3624b; actual=_rsq_; run;

data _null_; if 0 then set j3624o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3624 rows=' rows;
else do; set j3624o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3624';
else put 'ERROR: ROUND8_FAIL=J3624 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3624:; quit;
