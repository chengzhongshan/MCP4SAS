/* F1874 summary_marginal_types, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1874a; do a=1 to 5; do b=1 to 2; x=1; output; end; end; run;
proc summary data=f1874a; class a b; types a b; var x; output out=f1874b sum=total; run;
proc sql; create table f1874o as select sum(_freq_) as actual from f1874b; quit;

data _null_; if 0 then set f1874o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1874 rows=' rows;
else do; set f1874o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND4_PASS=F1874';
else put 'ERROR: ROUND4_FAIL=F1874 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1874:; quit;
