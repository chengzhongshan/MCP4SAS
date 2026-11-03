/* F1618 univariate_quartile_def5, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1618a; do x=1 to 4*9; output; end; run;
proc univariate data=f1618a noprint pctldef=5; var x; output out=f1618b pctlpts=25 pctlpre=q; run;
data f1618o; set f1618b; actual=q25; run;

data _null_; if 0 then set f1618o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1618 rows=' rows;
else do; set f1618o; if not missing(actual) and abs(actual-(9.5))<=1e-9*max(1,abs(9.5)) then put 'ROUND4_PASS=F1618';
else put 'ERROR: ROUND4_FAIL=F1618 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1618:; quit;
