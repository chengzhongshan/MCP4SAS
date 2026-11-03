/* F1864 summary_complete_types, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1864a; do a=1 to 5; b=a; x=1; output; end; run;
proc summary data=f1864a nway completetypes; class a b; var x; output out=f1864b sum=total; run;
proc sql; create table f1864o as select sum(_freq_=0) as actual from f1864b; quit;

data _null_; if 0 then set f1864o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1864 rows=' rows;
else do; set f1864o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND4_PASS=F1864';
else put 'ERROR: ROUND4_FAIL=F1864 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1864:; quit;
