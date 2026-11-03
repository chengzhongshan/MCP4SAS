/* F1841 standard_unit_variance, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/colwide z score with proc standard.sas:2 */

data f1841a; do x=1 to 2+2; output; end; run;
proc standard data=f1841a out=f1841b mean=0 std=1; var x; run;
proc means data=f1841b noprint; var x; output out=f1841c mean=center var=variance; run;
data f1841o; set f1841c; actual=abs(center)+variance; run;

data _null_; if 0 then set f1841o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1841 rows=' rows;
else do; set f1841o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1841';
else put 'ERROR: ROUND4_FAIL=F1841 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1841:; quit;
