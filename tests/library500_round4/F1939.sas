/* F1939 online_welford_variance, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data f1939a; do x=1 to 10; output; end; run;
data f1939o; set f1939a end=last; retain count 0 center 0 m2 0; count+1; delta=x-center; center=center+delta/count; m2=m2+delta*(x-center); if last; actual=m2/(count-1); run;

data _null_; if 0 then set f1939o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1939 rows=' rows;
else do; set f1939o; if not missing(actual) and abs(actual-(9.16666666666667))<=1e-9*max(1,abs(9.16666666666667)) then put 'ROUND4_PASS=F1939';
else put 'ERROR: ROUND4_FAIL=F1939 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1939:; quit;
