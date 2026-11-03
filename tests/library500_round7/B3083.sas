/* B3083 delete_and_explicit_outputs, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3083a; do x=1 to 2*4; output; end; run;
data b3083b; set b3083a; if mod(x,2)=1 then delete; output; output; run;
proc sql; create table b3083o as select sum(x) as actual from b3083b; quit;

data _null_; if 0 then set b3083o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3083 rows=' rows;
else do; set b3083o; if not missing(actual) and abs(actual-(40))<=1e-9*max(1,abs(40)) then put 'ROUND7_PASS=B3083';
else put 'ERROR: ROUND7_FAIL=B3083 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3083:; quit;
