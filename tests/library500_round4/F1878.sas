/* F1878 summary_marginal_types, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1878a; do a=1 to 9; do b=1 to 2; x=1; output; end; end; run;
proc summary data=f1878a; class a b; types a b; var x; output out=f1878b sum=total; run;
proc sql; create table f1878o as select sum(_freq_) as actual from f1878b; quit;

data _null_; if 0 then set f1878o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1878 rows=' rows;
else do; set f1878o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND4_PASS=F1878';
else put 'ERROR: ROUND4_FAIL=F1878 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1878:; quit;
