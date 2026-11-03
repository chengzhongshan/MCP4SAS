/* F1535 means_coefficient_variation, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1535a; do x=1 to 6; output; end; run;
proc means data=f1535a noprint; var x; output out=f1535o cv=actual; run;

data _null_; if 0 then set f1535o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1535 rows=' rows;
else do; set f1535o; if not missing(actual) and abs(actual-(53.4522483824849))<=1e-9*max(1,abs(53.4522483824849)) then put 'ROUND4_PASS=F1535';
else put 'ERROR: ROUND4_FAIL=F1535 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1535:; quit;
