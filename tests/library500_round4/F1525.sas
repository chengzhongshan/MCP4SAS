/* F1525 means_standard_error, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1525a; do x=1 to 6; output; end; run;
proc means data=f1525a noprint; var x; output out=f1525o stderr=actual; run;

data _null_; if 0 then set f1525o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1525 rows=' rows;
else do; set f1525o; if not missing(actual) and abs(actual-(0.763762615825973))<=1e-9*max(1,abs(0.763762615825973)) then put 'ROUND4_PASS=F1525';
else put 'ERROR: ROUND4_FAIL=F1525 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1525:; quit;
