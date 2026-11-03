/* F1875 summary_marginal_types, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1875a; do a=1 to 6; do b=1 to 2; x=1; output; end; end; run;
proc summary data=f1875a; class a b; types a b; var x; output out=f1875b sum=total; run;
proc sql; create table f1875o as select sum(_freq_) as actual from f1875b; quit;

data _null_; if 0 then set f1875o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1875 rows=' rows;
else do; set f1875o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND4_PASS=F1875';
else put 'ERROR: ROUND4_FAIL=F1875 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1875:; quit;
