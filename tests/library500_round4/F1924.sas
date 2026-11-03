/* F1924 frequency_row_expansion, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:13 */

data f1924a; do k=1 to 5; freq=k; output; end; run;
data f1924b; set f1924a; do rep=1 to freq; output; end; run;
proc sql; create table f1924o as select sum(k) as actual from f1924b; quit;

data _null_; if 0 then set f1924o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1924 rows=' rows;
else do; set f1924o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND4_PASS=F1924';
else put 'ERROR: ROUND4_FAIL=F1924 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1924:; quit;
