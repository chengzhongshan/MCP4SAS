/* F1865 summary_complete_types, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1865a; do a=1 to 6; b=a; x=1; output; end; run;
proc summary data=f1865a nway completetypes; class a b; var x; output out=f1865b sum=total; run;
proc sql; create table f1865o as select sum(_freq_=0) as actual from f1865b; quit;

data _null_; if 0 then set f1865o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1865 rows=' rows;
else do; set f1865o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND4_PASS=F1865';
else put 'ERROR: ROUND4_FAIL=F1865 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1865:; quit;
