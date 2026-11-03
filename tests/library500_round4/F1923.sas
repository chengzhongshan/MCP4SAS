/* F1923 frequency_row_expansion, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:13 */

data f1923a; do k=1 to 4; freq=k; output; end; run;
data f1923b; set f1923a; do rep=1 to freq; output; end; run;
proc sql; create table f1923o as select sum(k) as actual from f1923b; quit;

data _null_; if 0 then set f1923o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1923 rows=' rows;
else do; set f1923o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND4_PASS=F1923';
else put 'ERROR: ROUND4_FAIL=F1923 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1923:; quit;
