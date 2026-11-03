/* F1847 standard_unit_variance, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/colwide z score with proc standard.sas:2 */

data f1847a; do x=1 to 8+2; output; end; run;
proc standard data=f1847a out=f1847b mean=0 std=1; var x; run;
proc means data=f1847b noprint; var x; output out=f1847c mean=center var=variance; run;
data f1847o; set f1847c; actual=abs(center)+variance; run;

data _null_; if 0 then set f1847o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1847 rows=' rows;
else do; set f1847o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1847';
else put 'ERROR: ROUND4_FAIL=F1847 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1847:; quit;
