/* F1871 summary_marginal_types, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1871a; do a=1 to 2; do b=1 to 2; x=1; output; end; end; run;
proc summary data=f1871a; class a b; types a b; var x; output out=f1871b sum=total; run;
proc sql; create table f1871o as select sum(_freq_) as actual from f1871b; quit;

data _null_; if 0 then set f1871o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1871 rows=' rows;
else do; set f1871o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND4_PASS=F1871';
else put 'ERROR: ROUND4_FAIL=F1871 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1871:; quit;
