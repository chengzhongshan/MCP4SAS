/* F1880 summary_marginal_types, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1880a; do a=1 to 11; do b=1 to 2; x=1; output; end; end; run;
proc summary data=f1880a; class a b; types a b; var x; output out=f1880b sum=total; run;
proc sql; create table f1880o as select sum(_freq_) as actual from f1880b; quit;

data _null_; if 0 then set f1880o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1880 rows=' rows;
else do; set f1880o; if not missing(actual) and abs(actual-(44))<=1e-9*max(1,abs(44)) then put 'ROUND4_PASS=F1880';
else put 'ERROR: ROUND4_FAIL=F1880 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1880:; quit;
