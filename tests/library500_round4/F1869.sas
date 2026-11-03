/* F1869 summary_complete_types, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1869a; do a=1 to 10; b=a; x=1; output; end; run;
proc summary data=f1869a nway completetypes; class a b; var x; output out=f1869b sum=total; run;
proc sql; create table f1869o as select sum(_freq_=0) as actual from f1869b; quit;

data _null_; if 0 then set f1869o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1869 rows=' rows;
else do; set f1869o; if not missing(actual) and abs(actual-(90))<=1e-9*max(1,abs(90)) then put 'ROUND4_PASS=F1869';
else put 'ERROR: ROUND4_FAIL=F1869 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1869:; quit;
