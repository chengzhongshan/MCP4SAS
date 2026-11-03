/* F1850 standard_unit_variance, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/colwide z score with proc standard.sas:2 */

data f1850a; do x=1 to 11+2; output; end; run;
proc standard data=f1850a out=f1850b mean=0 std=1; var x; run;
proc means data=f1850b noprint; var x; output out=f1850c mean=center var=variance; run;
data f1850o; set f1850c; actual=abs(center)+variance; run;

data _null_; if 0 then set f1850o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1850 rows=' rows;
else do; set f1850o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1850';
else put 'ERROR: ROUND4_FAIL=F1850 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1850:; quit;
