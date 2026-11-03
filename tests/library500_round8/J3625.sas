/* J3625 reg_perfect_fit_rsquare, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:522 */

data j3625a; do x=1 to 6+2; y=7+4*x; output; end; run;
proc reg data=j3625a outest=j3625b rsquare noprint; model y=x; run; quit;
data j3625o; set j3625b; actual=_rsq_; run;

data _null_; if 0 then set j3625o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3625 rows=' rows;
else do; set j3625o; if not missing(actual) and abs(actual-(1))<=1e-6*max(1,abs(1)) then put 'ROUND8_PASS=J3625';
else put 'ERROR: ROUND8_FAIL=J3625 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3625:; quit;
