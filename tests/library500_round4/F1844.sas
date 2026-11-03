/* F1844 standard_unit_variance, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/colwide z score with proc standard.sas:2 */

data f1844a; do x=1 to 5+2; output; end; run;
proc standard data=f1844a out=f1844b mean=0 std=1; var x; run;
proc means data=f1844b noprint; var x; output out=f1844c mean=center var=variance; run;
data f1844o; set f1844c; actual=abs(center)+variance; run;

data _null_; if 0 then set f1844o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1844 rows=' rows;
else do; set f1844o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1844';
else put 'ERROR: ROUND4_FAIL=F1844 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1844:; quit;
