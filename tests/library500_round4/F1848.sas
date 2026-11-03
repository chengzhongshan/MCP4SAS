/* F1848 standard_unit_variance, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/colwide z score with proc standard.sas:2 */

data f1848a; do x=1 to 9+2; output; end; run;
proc standard data=f1848a out=f1848b mean=0 std=1; var x; run;
proc means data=f1848b noprint; var x; output out=f1848c mean=center var=variance; run;
data f1848o; set f1848c; actual=abs(center)+variance; run;

data _null_; if 0 then set f1848o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1848 rows=' rows;
else do; set f1848o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1848';
else put 'ERROR: ROUND4_FAIL=F1848 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1848:; quit;
