/* F1861 summary_complete_types, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1861a; do a=1 to 2; b=a; x=1; output; end; run;
proc summary data=f1861a nway completetypes; class a b; var x; output out=f1861b sum=total; run;
proc sql; create table f1861o as select sum(_freq_=0) as actual from f1861b; quit;

data _null_; if 0 then set f1861o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1861 rows=' rows;
else do; set f1861o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND4_PASS=F1861';
else put 'ERROR: ROUND4_FAIL=F1861 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1861:; quit;
