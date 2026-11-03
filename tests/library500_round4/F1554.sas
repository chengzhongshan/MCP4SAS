/* F1554 means_freq_replication, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1554a; do x=1 to 5; reps=2; output; end; run;
proc means data=f1554a noprint; var x; freq reps; output out=f1554o var=actual; run;

data _null_; if 0 then set f1554o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1554 rows=' rows;
else do; set f1554o; if not missing(actual) and abs(actual-(2.22222222222222))<=1e-9*max(1,abs(2.22222222222222)) then put 'ROUND4_PASS=F1554';
else put 'ERROR: ROUND4_FAIL=F1554 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1554:; quit;
