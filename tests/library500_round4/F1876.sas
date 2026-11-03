/* F1876 summary_marginal_types, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1876a; do a=1 to 7; do b=1 to 2; x=1; output; end; end; run;
proc summary data=f1876a; class a b; types a b; var x; output out=f1876b sum=total; run;
proc sql; create table f1876o as select sum(_freq_) as actual from f1876b; quit;

data _null_; if 0 then set f1876o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1876 rows=' rows;
else do; set f1876o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND4_PASS=F1876';
else put 'ERROR: ROUND4_FAIL=F1876 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1876:; quit;
