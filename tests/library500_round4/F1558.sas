/* F1558 means_freq_replication, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1558a; do x=1 to 9; reps=2; output; end; run;
proc means data=f1558a noprint; var x; freq reps; output out=f1558o var=actual; run;

data _null_; if 0 then set f1558o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1558 rows=' rows;
else do; set f1558o; if not missing(actual) and abs(actual-(7.05882352941176))<=1e-9*max(1,abs(7.05882352941176)) then put 'ROUND4_PASS=F1558';
else put 'ERROR: ROUND4_FAIL=F1558 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1558:; quit;
