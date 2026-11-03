/* F1557 means_freq_replication, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1557a; do x=1 to 8; reps=2; output; end; run;
proc means data=f1557a noprint; var x; freq reps; output out=f1557o var=actual; run;

data _null_; if 0 then set f1557o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1557 rows=' rows;
else do; set f1557o; if not missing(actual) and abs(actual-(5.6))<=1e-9*max(1,abs(5.6)) then put 'ROUND4_PASS=F1557';
else put 'ERROR: ROUND4_FAIL=F1557 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1557:; quit;
