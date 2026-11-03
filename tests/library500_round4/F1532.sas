/* F1532 means_coefficient_variation, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1532a; do x=1 to 3; output; end; run;
proc means data=f1532a noprint; var x; output out=f1532o cv=actual; run;

data _null_; if 0 then set f1532o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1532 rows=' rows;
else do; set f1532o; if not missing(actual) and abs(actual-(50))<=1e-9*max(1,abs(50)) then put 'ROUND4_PASS=F1532';
else put 'ERROR: ROUND4_FAIL=F1532 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1532:; quit;
