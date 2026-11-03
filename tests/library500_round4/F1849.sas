/* F1849 standard_unit_variance, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/colwide z score with proc standard.sas:2 */

data f1849a; do x=1 to 10+2; output; end; run;
proc standard data=f1849a out=f1849b mean=0 std=1; var x; run;
proc means data=f1849b noprint; var x; output out=f1849c mean=center var=variance; run;
data f1849o; set f1849c; actual=abs(center)+variance; run;

data _null_; if 0 then set f1849o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1849 rows=' rows;
else do; set f1849o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1849';
else put 'ERROR: ROUND4_FAIL=F1849 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1849:; quit;
