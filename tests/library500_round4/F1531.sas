/* F1531 means_coefficient_variation, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1531a; do x=1 to 2; output; end; run;
proc means data=f1531a noprint; var x; output out=f1531o cv=actual; run;

data _null_; if 0 then set f1531o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1531 rows=' rows;
else do; set f1531o; if not missing(actual) and abs(actual-(47.1404520791032))<=1e-9*max(1,abs(47.1404520791032)) then put 'ROUND4_PASS=F1531';
else put 'ERROR: ROUND4_FAIL=F1531 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1531:; quit;
