/* B3090 delete_and_explicit_outputs, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3090a; do x=1 to 2*11; output; end; run;
data b3090b; set b3090a; if mod(x,2)=1 then delete; output; output; run;
proc sql; create table b3090o as select sum(x) as actual from b3090b; quit;

data _null_; if 0 then set b3090o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3090 rows=' rows;
else do; set b3090o; if not missing(actual) and abs(actual-(264))<=1e-9*max(1,abs(264)) then put 'ROUND7_PASS=B3090';
else put 'ERROR: ROUND7_FAIL=B3090 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3090:; quit;
