/* J3626 reg_perfect_fit_rsquare, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3626a; do x=1 to 7+2; y=7+4*x; output; end; run;
proc reg data=j3626a outest=j3626b rsquare noprint; model y=x; run; quit;
data j3626o; set j3626b; actual=_rsq_; run;

data _null_; if 0 then set j3626o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3626 rows=' rows;
else do; set j3626o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3626';
else put 'ERROR: ROUND8_FAIL=J3626 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3626:; quit;
