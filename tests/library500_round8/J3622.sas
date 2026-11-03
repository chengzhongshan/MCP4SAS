/* J3622 reg_perfect_fit_rsquare, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3622a; do x=1 to 3+2; y=7+4*x; output; end; run;
proc reg data=j3622a outest=j3622b rsquare noprint; model y=x; run; quit;
data j3622o; set j3622b; actual=_rsq_; run;

data _null_; if 0 then set j3622o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3622 rows=' rows;
else do; set j3622o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3622';
else put 'ERROR: ROUND8_FAIL=J3622 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3622:; quit;
