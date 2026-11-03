/* F1570 means_group_variances, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1570a; do grp=1 to 2; do x=1 to 11; y=grp*x; output; end; end; run;
proc means data=f1570a noprint nway; class grp; var y; output out=f1570b var=value; run;
proc sql; create table f1570o as select sum(value) as actual from f1570b; quit;

data _null_; if 0 then set f1570o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1570 rows=' rows;
else do; set f1570o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND4_PASS=F1570';
else put 'ERROR: ROUND4_FAIL=F1570 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1570:; quit;
