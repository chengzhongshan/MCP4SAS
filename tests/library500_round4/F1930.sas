/* F1930 frequency_row_expansion, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:13 */

data f1930a; do k=1 to 11; freq=k; output; end; run;
data f1930b; set f1930a; do rep=1 to freq; output; end; run;
proc sql; create table f1930o as select sum(k) as actual from f1930b; quit;

data _null_; if 0 then set f1930o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1930 rows=' rows;
else do; set f1930o; if not missing(actual) and abs(actual-(506))<=1e-9*max(1,abs(506)) then put 'ROUND4_PASS=F1930';
else put 'ERROR: ROUND4_FAIL=F1930 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1930:; quit;
