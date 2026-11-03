/* F1862 summary_complete_types, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1862a; do a=1 to 3; b=a; x=1; output; end; run;
proc summary data=f1862a nway completetypes; class a b; var x; output out=f1862b sum=total; run;
proc sql; create table f1862o as select sum(_freq_=0) as actual from f1862b; quit;

data _null_; if 0 then set f1862o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1862 rows=' rows;
else do; set f1862o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1862';
else put 'ERROR: ROUND4_FAIL=F1862 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1862:; quit;
