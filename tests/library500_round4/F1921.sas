/* F1921 frequency_row_expansion, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:13 */

data f1921a; do k=1 to 2; freq=k; output; end; run;
data f1921b; set f1921a; do rep=1 to freq; output; end; run;
proc sql; create table f1921o as select sum(k) as actual from f1921b; quit;

data _null_; if 0 then set f1921o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1921 rows=' rows;
else do; set f1921o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1921';
else put 'ERROR: ROUND4_FAIL=F1921 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1921:; quit;
