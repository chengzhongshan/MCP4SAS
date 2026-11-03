/* F1523 means_standard_error, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1523a; do x=1 to 4; output; end; run;
proc means data=f1523a noprint; var x; output out=f1523o stderr=actual; run;

data _null_; if 0 then set f1523o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1523 rows=' rows;
else do; set f1523o; if not missing(actual) and abs(actual-(0.645497224367903))<=1e-9*max(1,abs(0.645497224367903)) then put 'ROUND4_PASS=F1523';
else put 'ERROR: ROUND4_FAIL=F1523 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1523:; quit;
