/* F1933 online_welford_variance, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:18 */

data f1933a; do x=1 to 4; output; end; run;
data f1933o; set f1933a end=last; retain count 0 center 0 m2 0; count+1; delta=x-center; center=center+delta/count; m2=m2+delta*(x-center); if last; actual=m2/(count-1); run;

data _null_; if 0 then set f1933o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1933 rows=' rows;
else do; set f1933o; if not missing(actual) and abs(actual-(1.66666666666667))<=1e-9*max(1,abs(1.66666666666667)) then put 'ROUND4_PASS=F1933';
else put 'ERROR: ROUND4_FAIL=F1933 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1933:; quit;
