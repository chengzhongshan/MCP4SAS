/* F1927 frequency_row_expansion, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:13 */

data f1927a; do k=1 to 8; freq=k; output; end; run;
data f1927b; set f1927a; do rep=1 to freq; output; end; run;
proc sql; create table f1927o as select sum(k) as actual from f1927b; quit;

data _null_; if 0 then set f1927o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1927 rows=' rows;
else do; set f1927o; if not missing(actual) and abs(actual-(204))<=1e-9*max(1,abs(204)) then put 'ROUND4_PASS=F1927';
else put 'ERROR: ROUND4_FAIL=F1927 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1927:; quit;
