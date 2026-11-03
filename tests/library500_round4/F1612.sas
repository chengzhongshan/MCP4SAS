/* F1612 univariate_quartile_def5, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1612a; do x=1 to 4*3; output; end; run;
proc univariate data=f1612a noprint pctldef=5; var x; output out=f1612b pctlpts=25 pctlpre=q; run;
data f1612o; set f1612b; actual=q25; run;

data _null_; if 0 then set f1612o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1612 rows=' rows;
else do; set f1612o; if not missing(actual) and abs(actual-(3.5))<=1e-9*max(1,abs(3.5)) then put 'ROUND4_PASS=F1612';
else put 'ERROR: ROUND4_FAIL=F1612 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1612:; quit;
