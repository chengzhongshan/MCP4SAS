/* F1866 summary_complete_types, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1866a; do a=1 to 7; b=a; x=1; output; end; run;
proc summary data=f1866a nway completetypes; class a b; var x; output out=f1866b sum=total; run;
proc sql; create table f1866o as select sum(_freq_=0) as actual from f1866b; quit;

data _null_; if 0 then set f1866o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1866 rows=' rows;
else do; set f1866o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND4_PASS=F1866';
else put 'ERROR: ROUND4_FAIL=F1866 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1866:; quit;
