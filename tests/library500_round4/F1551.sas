/* F1551 means_freq_replication, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1551a; do x=1 to 2; reps=2; output; end; run;
proc means data=f1551a noprint; var x; freq reps; output out=f1551o var=actual; run;

data _null_; if 0 then set f1551o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1551 rows=' rows;
else do; set f1551o; if not missing(actual) and abs(actual-(0.333333333333333))<=1e-9*max(1,abs(0.333333333333333)) then put 'ROUND4_PASS=F1551';
else put 'ERROR: ROUND4_FAIL=F1551 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1551:; quit;
