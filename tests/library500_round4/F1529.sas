/* F1529 means_standard_error, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1529a; do x=1 to 10; output; end; run;
proc means data=f1529a noprint; var x; output out=f1529o stderr=actual; run;

data _null_; if 0 then set f1529o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1529 rows=' rows;
else do; set f1529o; if not missing(actual) and abs(actual-(0.957427107756338))<=1e-9*max(1,abs(0.957427107756338)) then put 'ROUND4_PASS=F1529';
else put 'ERROR: ROUND4_FAIL=F1529 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1529:; quit;
