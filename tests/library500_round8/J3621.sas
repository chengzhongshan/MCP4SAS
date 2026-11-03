/* J3621 reg_perfect_fit_rsquare, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3621a; do x=1 to 2+2; y=7+4*x; output; end; run;
proc reg data=j3621a outest=j3621b rsquare noprint; model y=x; run; quit;
data j3621o; set j3621b; actual=_rsq_; run;

data _null_; if 0 then set j3621o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3621 rows=' rows;
else do; set j3621o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3621';
else put 'ERROR: ROUND8_FAIL=J3621 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3621:; quit;
