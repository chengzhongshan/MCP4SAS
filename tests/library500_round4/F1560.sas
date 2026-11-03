/* F1560 means_freq_replication, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1560a; do x=1 to 11; reps=2; output; end; run;
proc means data=f1560a noprint; var x; freq reps; output out=f1560o var=actual; run;

data _null_; if 0 then set f1560o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1560 rows=' rows;
else do; set f1560o; if not missing(actual) and abs(actual-(10.4761904761905))<=1e-9*max(1,abs(10.4761904761905)) then put 'ROUND4_PASS=F1560';
else put 'ERROR: ROUND4_FAIL=F1560 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1560:; quit;
