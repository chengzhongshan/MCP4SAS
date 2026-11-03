/* F1611 univariate_quartile_def5, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1611a; do x=1 to 4*2; output; end; run;
proc univariate data=f1611a noprint pctldef=5; var x; output out=f1611b pctlpts=25 pctlpre=q; run;
data f1611o; set f1611b; actual=q25; run;

data _null_; if 0 then set f1611o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1611 rows=' rows;
else do; set f1611o; if not missing(actual) and abs(actual-(2.5))<=1e-9*max(1,abs(2.5)) then put 'ROUND4_PASS=F1611';
else put 'ERROR: ROUND4_FAIL=F1611 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1611:; quit;
