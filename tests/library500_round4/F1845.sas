/* F1845 standard_unit_variance, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/colwide z score with proc standard.sas:2 */

data f1845a; do x=1 to 6+2; output; end; run;
proc standard data=f1845a out=f1845b mean=0 std=1; var x; run;
proc means data=f1845b noprint; var x; output out=f1845c mean=center var=variance; run;
data f1845o; set f1845c; actual=abs(center)+variance; run;

data _null_; if 0 then set f1845o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1845 rows=' rows;
else do; set f1845o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1845';
else put 'ERROR: ROUND4_FAIL=F1845 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1845:; quit;
