/* F1559 means_freq_replication, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1559a; do x=1 to 10; reps=2; output; end; run;
proc means data=f1559a noprint; var x; freq reps; output out=f1559o var=actual; run;

data _null_; if 0 then set f1559o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1559 rows=' rows;
else do; set f1559o; if not missing(actual) and abs(actual-(8.68421052631579))<=1e-9*max(1,abs(8.68421052631579)) then put 'ROUND4_PASS=F1559';
else put 'ERROR: ROUND4_FAIL=F1559 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1559:; quit;
