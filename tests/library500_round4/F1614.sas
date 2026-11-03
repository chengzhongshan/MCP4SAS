/* F1614 univariate_quartile_def5, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1614a; do x=1 to 4*5; output; end; run;
proc univariate data=f1614a noprint pctldef=5; var x; output out=f1614b pctlpts=25 pctlpre=q; run;
data f1614o; set f1614b; actual=q25; run;

data _null_; if 0 then set f1614o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1614 rows=' rows;
else do; set f1614o; if not missing(actual) and abs(actual-(5.5))<=1e-9*max(1,abs(5.5)) then put 'ROUND4_PASS=F1614';
else put 'ERROR: ROUND4_FAIL=F1614 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1614:; quit;
