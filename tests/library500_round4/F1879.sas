/* F1879 summary_marginal_types, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1879a; do a=1 to 10; do b=1 to 2; x=1; output; end; end; run;
proc summary data=f1879a; class a b; types a b; var x; output out=f1879b sum=total; run;
proc sql; create table f1879o as select sum(_freq_) as actual from f1879b; quit;

data _null_; if 0 then set f1879o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1879 rows=' rows;
else do; set f1879o; if not missing(actual) and abs(actual-(40))<=1e-9*max(1,abs(40)) then put 'ROUND4_PASS=F1879';
else put 'ERROR: ROUND4_FAIL=F1879 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1879:; quit;
