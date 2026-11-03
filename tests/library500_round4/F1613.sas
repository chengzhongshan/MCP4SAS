/* F1613 univariate_quartile_def5, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1613a; do x=1 to 4*4; output; end; run;
proc univariate data=f1613a noprint pctldef=5; var x; output out=f1613b pctlpts=25 pctlpre=q; run;
data f1613o; set f1613b; actual=q25; run;

data _null_; if 0 then set f1613o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1613 rows=' rows;
else do; set f1613o; if not missing(actual) and abs(actual-(4.5))<=1e-9*max(1,abs(4.5)) then put 'ROUND4_PASS=F1613';
else put 'ERROR: ROUND4_FAIL=F1613 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1613:; quit;
