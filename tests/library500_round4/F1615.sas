/* F1615 univariate_quartile_def5, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1615a; do x=1 to 4*6; output; end; run;
proc univariate data=f1615a noprint pctldef=5; var x; output out=f1615b pctlpts=25 pctlpre=q; run;
data f1615o; set f1615b; actual=q25; run;

data _null_; if 0 then set f1615o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1615 rows=' rows;
else do; set f1615o; if not missing(actual) and abs(actual-(6.5))<=1e-9*max(1,abs(6.5)) then put 'ROUND4_PASS=F1615';
else put 'ERROR: ROUND4_FAIL=F1615 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1615:; quit;
