/* F1533 means_coefficient_variation, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1533a; do x=1 to 4; output; end; run;
proc means data=f1533a noprint; var x; output out=f1533o cv=actual; run;

data _null_; if 0 then set f1533o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1533 rows=' rows;
else do; set f1533o; if not missing(actual) and abs(actual-(51.6397779494322))<=1e-9*max(1,abs(51.6397779494322)) then put 'ROUND4_PASS=F1533';
else put 'ERROR: ROUND4_FAIL=F1533 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1533:; quit;
