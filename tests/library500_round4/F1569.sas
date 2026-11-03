/* F1569 means_group_variances, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1569a; do grp=1 to 2; do x=1 to 10; y=grp*x; output; end; end; run;
proc means data=f1569a noprint nway; class grp; var y; output out=f1569b var=value; run;
proc sql; create table f1569o as select sum(value) as actual from f1569b; quit;

data _null_; if 0 then set f1569o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1569 rows=' rows;
else do; set f1569o; if not missing(actual) and abs(actual-(45.8333333333333))<=1e-9*max(1,abs(45.8333333333333)) then put 'ROUND4_PASS=F1569';
else put 'ERROR: ROUND4_FAIL=F1569 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1569:; quit;
