/* F1562 means_group_variances, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1562a; do grp=1 to 2; do x=1 to 3; y=grp*x; output; end; end; run;
proc means data=f1562a noprint nway; class grp; var y; output out=f1562b var=value; run;
proc sql; create table f1562o as select sum(value) as actual from f1562b; quit;

data _null_; if 0 then set f1562o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1562 rows=' rows;
else do; set f1562o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1562';
else put 'ERROR: ROUND4_FAIL=F1562 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1562:; quit;
