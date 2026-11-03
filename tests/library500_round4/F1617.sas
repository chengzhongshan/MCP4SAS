/* F1617 univariate_quartile_def5, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1617a; do x=1 to 4*8; output; end; run;
proc univariate data=f1617a noprint pctldef=5; var x; output out=f1617b pctlpts=25 pctlpre=q; run;
data f1617o; set f1617b; actual=q25; run;

data _null_; if 0 then set f1617o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1617 rows=' rows;
else do; set f1617o; if not missing(actual) and abs(actual-(8.5))<=1e-9*max(1,abs(8.5)) then put 'ROUND4_PASS=F1617';
else put 'ERROR: ROUND4_FAIL=F1617 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1617:; quit;
