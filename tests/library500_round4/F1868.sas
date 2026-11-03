/* F1868 summary_complete_types, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1868a; do a=1 to 9; b=a; x=1; output; end; run;
proc summary data=f1868a nway completetypes; class a b; var x; output out=f1868b sum=total; run;
proc sql; create table f1868o as select sum(_freq_=0) as actual from f1868b; quit;

data _null_; if 0 then set f1868o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1868 rows=' rows;
else do; set f1868o; if not missing(actual) and abs(actual-(72))<=1e-9*max(1,abs(72)) then put 'ROUND4_PASS=F1868';
else put 'ERROR: ROUND4_FAIL=F1868 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1868:; quit;
