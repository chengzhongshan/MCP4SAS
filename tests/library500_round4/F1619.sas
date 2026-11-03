/* F1619 univariate_quartile_def5, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1619a; do x=1 to 4*10; output; end; run;
proc univariate data=f1619a noprint pctldef=5; var x; output out=f1619b pctlpts=25 pctlpre=q; run;
data f1619o; set f1619b; actual=q25; run;

data _null_; if 0 then set f1619o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1619 rows=' rows;
else do; set f1619o; if not missing(actual) and abs(actual-(10.5))<=1e-9*max(1,abs(10.5)) then put 'ROUND4_PASS=F1619';
else put 'ERROR: ROUND4_FAIL=F1619 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1619:; quit;
