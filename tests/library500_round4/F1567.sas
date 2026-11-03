/* F1567 means_group_variances, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1567a; do grp=1 to 2; do x=1 to 8; y=grp*x; output; end; end; run;
proc means data=f1567a noprint nway; class grp; var y; output out=f1567b var=value; run;
proc sql; create table f1567o as select sum(value) as actual from f1567b; quit;

data _null_; if 0 then set f1567o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1567 rows=' rows;
else do; set f1567o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND4_PASS=F1567';
else put 'ERROR: ROUND4_FAIL=F1567 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1567:; quit;
