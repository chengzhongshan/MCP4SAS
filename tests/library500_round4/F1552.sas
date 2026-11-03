/* F1552 means_freq_replication, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1552a; do x=1 to 3; reps=2; output; end; run;
proc means data=f1552a noprint; var x; freq reps; output out=f1552o var=actual; run;

data _null_; if 0 then set f1552o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1552 rows=' rows;
else do; set f1552o; if not missing(actual) and abs(actual-(0.8))<=1e-9*max(1,abs(0.8)) then put 'ROUND4_PASS=F1552';
else put 'ERROR: ROUND4_FAIL=F1552 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1552:; quit;
