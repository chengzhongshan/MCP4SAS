/* F1568 means_group_variances, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1568a; do grp=1 to 2; do x=1 to 9; y=grp*x; output; end; end; run;
proc means data=f1568a noprint nway; class grp; var y; output out=f1568b var=value; run;
proc sql; create table f1568o as select sum(value) as actual from f1568b; quit;

data _null_; if 0 then set f1568o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1568 rows=' rows;
else do; set f1568o; if not missing(actual) and abs(actual-(37.5))<=1e-9*max(1,abs(37.5)) then put 'ROUND4_PASS=F1568';
else put 'ERROR: ROUND4_FAIL=F1568 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1568:; quit;
