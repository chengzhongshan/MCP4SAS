/* F1867 summary_complete_types, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1867a; do a=1 to 8; b=a; x=1; output; end; run;
proc summary data=f1867a nway completetypes; class a b; var x; output out=f1867b sum=total; run;
proc sql; create table f1867o as select sum(_freq_=0) as actual from f1867b; quit;

data _null_; if 0 then set f1867o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1867 rows=' rows;
else do; set f1867o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND4_PASS=F1867';
else put 'ERROR: ROUND4_FAIL=F1867 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1867:; quit;
