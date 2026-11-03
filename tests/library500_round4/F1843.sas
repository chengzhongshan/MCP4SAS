/* F1843 standard_unit_variance, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/colwide z score with proc standard.sas:2 */

data f1843a; do x=1 to 4+2; output; end; run;
proc standard data=f1843a out=f1843b mean=0 std=1; var x; run;
proc means data=f1843b noprint; var x; output out=f1843c mean=center var=variance; run;
data f1843o; set f1843c; actual=abs(center)+variance; run;

data _null_; if 0 then set f1843o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1843 rows=' rows;
else do; set f1843o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1843';
else put 'ERROR: ROUND4_FAIL=F1843 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1843:; quit;
