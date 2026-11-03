/* F1540 means_coefficient_variation, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1540a; do x=1 to 11; output; end; run;
proc means data=f1540a noprint; var x; output out=f1540o cv=actual; run;

data _null_; if 0 then set f1540o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1540 rows=' rows;
else do; set f1540o; if not missing(actual) and abs(actual-(55.2770798392567))<=1e-9*max(1,abs(55.2770798392567)) then put 'ROUND4_PASS=F1540';
else put 'ERROR: ROUND4_FAIL=F1540 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1540:; quit;
