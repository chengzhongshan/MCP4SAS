/* F1863 summary_complete_types, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1863a; do a=1 to 4; b=a; x=1; output; end; run;
proc summary data=f1863a nway completetypes; class a b; var x; output out=f1863b sum=total; run;
proc sql; create table f1863o as select sum(_freq_=0) as actual from f1863b; quit;

data _null_; if 0 then set f1863o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1863 rows=' rows;
else do; set f1863o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND4_PASS=F1863';
else put 'ERROR: ROUND4_FAIL=F1863 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1863:; quit;
