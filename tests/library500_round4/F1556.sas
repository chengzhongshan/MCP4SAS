/* F1556 means_freq_replication, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1556a; do x=1 to 7; reps=2; output; end; run;
proc means data=f1556a noprint; var x; freq reps; output out=f1556o var=actual; run;

data _null_; if 0 then set f1556o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1556 rows=' rows;
else do; set f1556o; if not missing(actual) and abs(actual-(4.30769230769231))<=1e-9*max(1,abs(4.30769230769231)) then put 'ROUND4_PASS=F1556';
else put 'ERROR: ROUND4_FAIL=F1556 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1556:; quit;
