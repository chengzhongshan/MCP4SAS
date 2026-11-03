/* F1574 means_squared_range, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1574a; do x=1 to 5; y=x*x; output; end; run;
proc means data=f1574a noprint; var y; output out=f1574o range=actual; run;

data _null_; if 0 then set f1574o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1574 rows=' rows;
else do; set f1574o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND4_PASS=F1574';
else put 'ERROR: ROUND4_FAIL=F1574 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1574:; quit;
