/* F1842 standard_unit_variance, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/colwide z score with proc standard.sas:2 */

data f1842a; do x=1 to 3+2; output; end; run;
proc standard data=f1842a out=f1842b mean=0 std=1; var x; run;
proc means data=f1842b noprint; var x; output out=f1842c mean=center var=variance; run;
data f1842o; set f1842c; actual=abs(center)+variance; run;

data _null_; if 0 then set f1842o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1842 rows=' rows;
else do; set f1842o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1842';
else put 'ERROR: ROUND4_FAIL=F1842 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1842:; quit;
