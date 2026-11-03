/* F1938 online_welford_variance, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data f1938a; do x=1 to 9; output; end; run;
data f1938o; set f1938a end=last; retain count 0 center 0 m2 0; count+1; delta=x-center; center=center+delta/count; m2=m2+delta*(x-center); if last; actual=m2/(count-1); run;

data _null_; if 0 then set f1938o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1938 rows=' rows;
else do; set f1938o; if not missing(actual) and abs(actual-(7.5))<=1e-9*max(1,abs(7.5)) then put 'ROUND4_PASS=F1938';
else put 'ERROR: ROUND4_FAIL=F1938 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1938:; quit;
