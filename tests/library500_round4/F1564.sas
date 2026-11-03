/* F1564 means_group_variances, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1564a; do grp=1 to 2; do x=1 to 5; y=grp*x; output; end; end; run;
proc means data=f1564a noprint nway; class grp; var y; output out=f1564b var=value; run;
proc sql; create table f1564o as select sum(value) as actual from f1564b; quit;

data _null_; if 0 then set f1564o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1564 rows=' rows;
else do; set f1564o; if not missing(actual) and abs(actual-(12.5))<=1e-9*max(1,abs(12.5)) then put 'ROUND4_PASS=F1564';
else put 'ERROR: ROUND4_FAIL=F1564 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1564:; quit;
