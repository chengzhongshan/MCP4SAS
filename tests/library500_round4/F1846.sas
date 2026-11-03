/* F1846 standard_unit_variance, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/colwide z score with proc standard.sas:2 */

data f1846a; do x=1 to 7+2; output; end; run;
proc standard data=f1846a out=f1846b mean=0 std=1; var x; run;
proc means data=f1846b noprint; var x; output out=f1846c mean=center var=variance; run;
data f1846o; set f1846c; actual=abs(center)+variance; run;

data _null_; if 0 then set f1846o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1846 rows=' rows;
else do; set f1846o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1846';
else put 'ERROR: ROUND4_FAIL=F1846 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1846:; quit;
