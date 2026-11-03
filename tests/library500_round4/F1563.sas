/* F1563 means_group_variances, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1563a; do grp=1 to 2; do x=1 to 4; y=grp*x; output; end; end; run;
proc means data=f1563a noprint nway; class grp; var y; output out=f1563b var=value; run;
proc sql; create table f1563o as select sum(value) as actual from f1563b; quit;

data _null_; if 0 then set f1563o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1563 rows=' rows;
else do; set f1563o; if not missing(actual) and abs(actual-(8.33333333333333))<=1e-9*max(1,abs(8.33333333333333)) then put 'ROUND4_PASS=F1563';
else put 'ERROR: ROUND4_FAIL=F1563 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1563:; quit;
