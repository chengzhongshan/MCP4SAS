/* F1620 univariate_quartile_def5, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1620a; do x=1 to 4*11; output; end; run;
proc univariate data=f1620a noprint pctldef=5; var x; output out=f1620b pctlpts=25 pctlpre=q; run;
data f1620o; set f1620b; actual=q25; run;

data _null_; if 0 then set f1620o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1620 rows=' rows;
else do; set f1620o; if not missing(actual) and abs(actual-(11.5))<=1e-9*max(1,abs(11.5)) then put 'ROUND4_PASS=F1620';
else put 'ERROR: ROUND4_FAIL=F1620 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1620:; quit;
