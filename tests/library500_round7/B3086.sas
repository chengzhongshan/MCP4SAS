/* B3086 delete_and_explicit_outputs, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3086a; do x=1 to 2*7; output; end; run;
data b3086b; set b3086a; if mod(x,2)=1 then delete; output; output; run;
proc sql; create table b3086o as select sum(x) as actual from b3086b; quit;

data _null_; if 0 then set b3086o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3086 rows=' rows;
else do; set b3086o; if not missing(actual) and abs(actual-(112))<=1e-9*max(1,abs(112)) then put 'ROUND7_PASS=B3086';
else put 'ERROR: ROUND7_FAIL=B3086 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3086:; quit;
