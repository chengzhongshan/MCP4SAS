/* F1929 frequency_row_expansion, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:13 */

data f1929a; do k=1 to 10; freq=k; output; end; run;
data f1929b; set f1929a; do rep=1 to freq; output; end; run;
proc sql; create table f1929o as select sum(k) as actual from f1929b; quit;

data _null_; if 0 then set f1929o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1929 rows=' rows;
else do; set f1929o; if not missing(actual) and abs(actual-(385))<=1e-9*max(1,abs(385)) then put 'ROUND4_PASS=F1929';
else put 'ERROR: ROUND4_FAIL=F1929 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1929:; quit;
