/* F1561 means_group_variances, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1561a; do grp=1 to 2; do x=1 to 2; y=grp*x; output; end; end; run;
proc means data=f1561a noprint nway; class grp; var y; output out=f1561b var=value; run;
proc sql; create table f1561o as select sum(value) as actual from f1561b; quit;

data _null_; if 0 then set f1561o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1561 rows=' rows;
else do; set f1561o; if not missing(actual) and abs(actual-(2.5))<=1e-9*max(1,abs(2.5)) then put 'ROUND4_PASS=F1561';
else put 'ERROR: ROUND4_FAIL=F1561 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1561:; quit;
