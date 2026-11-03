/* F1922 frequency_row_expansion, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:13 */

data f1922a; do k=1 to 3; freq=k; output; end; run;
data f1922b; set f1922a; do rep=1 to freq; output; end; run;
proc sql; create table f1922o as select sum(k) as actual from f1922b; quit;

data _null_; if 0 then set f1922o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1922 rows=' rows;
else do; set f1922o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND4_PASS=F1922';
else put 'ERROR: ROUND4_FAIL=F1922 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1922:; quit;
