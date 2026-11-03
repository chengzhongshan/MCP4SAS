/* J3605 reg_quadratic_coefficient, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3605a; do x=1 to 6+3; x2=x*x; y=5+2*x+3*x2; output; end; run;
proc reg data=j3605a outest=j3605b noprint; model y=x x2; run; quit;
data j3605o; set j3605b; actual=x2; run;

data _null_; if 0 then set j3605o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3605 rows=' rows;
else do; set j3605o; if not missing(actual) and abs(actual-(3))<=1e-6*max(1,abs(3)) then put 'ROUND8_PASS=J3605';
else put 'ERROR: ROUND8_FAIL=J3605 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3605:; quit;
