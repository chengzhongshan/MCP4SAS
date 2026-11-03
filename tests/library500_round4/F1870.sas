/* F1870 summary_complete_types, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1870a; do a=1 to 11; b=a; x=1; output; end; run;
proc summary data=f1870a nway completetypes; class a b; var x; output out=f1870b sum=total; run;
proc sql; create table f1870o as select sum(_freq_=0) as actual from f1870b; quit;

data _null_; if 0 then set f1870o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1870 rows=' rows;
else do; set f1870o; if not missing(actual) and abs(actual-(110))<=1e-9*max(1,abs(110)) then put 'ROUND4_PASS=F1870';
else put 'ERROR: ROUND4_FAIL=F1870 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1870:; quit;
