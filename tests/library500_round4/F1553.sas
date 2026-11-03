/* F1553 means_freq_replication, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1553a; do x=1 to 4; reps=2; output; end; run;
proc means data=f1553a noprint; var x; freq reps; output out=f1553o var=actual; run;

data _null_; if 0 then set f1553o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1553 rows=' rows;
else do; set f1553o; if not missing(actual) and abs(actual-(1.42857142857143))<=1e-9*max(1,abs(1.42857142857143)) then put 'ROUND4_PASS=F1553';
else put 'ERROR: ROUND4_FAIL=F1553 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1553:; quit;
