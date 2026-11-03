/* F1928 frequency_row_expansion, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:13 */

data f1928a; do k=1 to 9; freq=k; output; end; run;
data f1928b; set f1928a; do rep=1 to freq; output; end; run;
proc sql; create table f1928o as select sum(k) as actual from f1928b; quit;

data _null_; if 0 then set f1928o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1928 rows=' rows;
else do; set f1928o; if not missing(actual) and abs(actual-(285))<=1e-9*max(1,abs(285)) then put 'ROUND4_PASS=F1928';
else put 'ERROR: ROUND4_FAIL=F1928 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1928:; quit;
