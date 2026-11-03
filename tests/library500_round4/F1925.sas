/* F1925 frequency_row_expansion, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:13 */

data f1925a; do k=1 to 6; freq=k; output; end; run;
data f1925b; set f1925a; do rep=1 to freq; output; end; run;
proc sql; create table f1925o as select sum(k) as actual from f1925b; quit;

data _null_; if 0 then set f1925o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1925 rows=' rows;
else do; set f1925o; if not missing(actual) and abs(actual-(91))<=1e-9*max(1,abs(91)) then put 'ROUND4_PASS=F1925';
else put 'ERROR: ROUND4_FAIL=F1925 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1925:; quit;
