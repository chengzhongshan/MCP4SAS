/* B3089 delete_and_explicit_outputs, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3089a; do x=1 to 2*10; output; end; run;
data b3089b; set b3089a; if mod(x,2)=1 then delete; output; output; run;
proc sql; create table b3089o as select sum(x) as actual from b3089b; quit;

data _null_; if 0 then set b3089o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3089 rows=' rows;
else do; set b3089o; if not missing(actual) and abs(actual-(220))<=1e-9*max(1,abs(220)) then put 'ROUND7_PASS=B3089';
else put 'ERROR: ROUND7_FAIL=B3089 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3089:; quit;
