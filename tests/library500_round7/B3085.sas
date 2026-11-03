/* B3085 delete_and_explicit_outputs, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3085a; do x=1 to 2*6; output; end; run;
data b3085b; set b3085a; if mod(x,2)=1 then delete; output; output; run;
proc sql; create table b3085o as select sum(x) as actual from b3085b; quit;

data _null_; if 0 then set b3085o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3085 rows=' rows;
else do; set b3085o; if not missing(actual) and abs(actual-(84))<=1e-9*max(1,abs(84)) then put 'ROUND7_PASS=B3085';
else put 'ERROR: ROUND7_FAIL=B3085 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3085:; quit;
