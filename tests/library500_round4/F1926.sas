/* F1926 frequency_row_expansion, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:13 */

data f1926a; do k=1 to 7; freq=k; output; end; run;
data f1926b; set f1926a; do rep=1 to freq; output; end; run;
proc sql; create table f1926o as select sum(k) as actual from f1926b; quit;

data _null_; if 0 then set f1926o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1926 rows=' rows;
else do; set f1926o; if not missing(actual) and abs(actual-(140))<=1e-9*max(1,abs(140)) then put 'ROUND4_PASS=F1926';
else put 'ERROR: ROUND4_FAIL=F1926 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1926:; quit;
