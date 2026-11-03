/* F1565 means_group_variances, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1565a; do grp=1 to 2; do x=1 to 6; y=grp*x; output; end; end; run;
proc means data=f1565a noprint nway; class grp; var y; output out=f1565b var=value; run;
proc sql; create table f1565o as select sum(value) as actual from f1565b; quit;

data _null_; if 0 then set f1565o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1565 rows=' rows;
else do; set f1565o; if not missing(actual) and abs(actual-(17.5))<=1e-9*max(1,abs(17.5)) then put 'ROUND4_PASS=F1565';
else put 'ERROR: ROUND4_FAIL=F1565 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1565:; quit;
