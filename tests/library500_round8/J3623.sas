/* J3623 reg_perfect_fit_rsquare, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3623a; do x=1 to 4+2; y=7+4*x; output; end; run;
proc reg data=j3623a outest=j3623b rsquare noprint; model y=x; run; quit;
data j3623o; set j3623b; actual=_rsq_; run;

data _null_; if 0 then set j3623o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3623 rows=' rows;
else do; set j3623o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3623';
else put 'ERROR: ROUND8_FAIL=J3623 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3623:; quit;
