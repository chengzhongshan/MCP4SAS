/* F1530 means_standard_error, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1530a; do x=1 to 11; output; end; run;
proc means data=f1530a noprint; var x; output out=f1530o stderr=actual; run;

data _null_; if 0 then set f1530o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1530 rows=' rows;
else do; set f1530o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1530';
else put 'ERROR: ROUND4_FAIL=F1530 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1530:; quit;
