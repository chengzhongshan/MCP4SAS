/* F1566 means_group_variances, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1566a; do grp=1 to 2; do x=1 to 7; y=grp*x; output; end; end; run;
proc means data=f1566a noprint nway; class grp; var y; output out=f1566b var=value; run;
proc sql; create table f1566o as select sum(value) as actual from f1566b; quit;

data _null_; if 0 then set f1566o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1566 rows=' rows;
else do; set f1566o; if not missing(actual) and abs(actual-(23.3333333333333))<=1e-9*max(1,abs(23.3333333333333)) then put 'ROUND4_PASS=F1566';
else put 'ERROR: ROUND4_FAIL=F1566 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1566:; quit;
