/* F1877 summary_marginal_types, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1877a; do a=1 to 8; do b=1 to 2; x=1; output; end; end; run;
proc summary data=f1877a; class a b; types a b; var x; output out=f1877b sum=total; run;
proc sql; create table f1877o as select sum(_freq_) as actual from f1877b; quit;

data _null_; if 0 then set f1877o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1877 rows=' rows;
else do; set f1877o; if not missing(actual) and abs(actual-(32))<=1e-9*max(1,abs(32)) then put 'ROUND4_PASS=F1877';
else put 'ERROR: ROUND4_FAIL=F1877 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1877:; quit;
