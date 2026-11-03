/* F1555 means_freq_replication, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1555a; do x=1 to 6; reps=2; output; end; run;
proc means data=f1555a noprint; var x; freq reps; output out=f1555o var=actual; run;

data _null_; if 0 then set f1555o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1555 rows=' rows;
else do; set f1555o; if not missing(actual) and abs(actual-(3.18181818181818))<=1e-9*max(1,abs(3.18181818181818)) then put 'ROUND4_PASS=F1555';
else put 'ERROR: ROUND4_FAIL=F1555 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1555:; quit;
