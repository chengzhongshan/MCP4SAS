/* B3035 goto_local_label, N=6; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3035a; do x=1 to 6; if mod(x,2)=0 then goto even; score=x; goto emit;
even: score=10*x;
emit: output; end; stop; run;
proc sql; create table b3035o as select sum(score) as actual from b3035a; quit;

data _null_; if 0 then set b3035o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3035 rows=' rows;
else do; set b3035o; if not missing(actual) and abs(actual-(129))<=1e-9*max(1,abs(129)) then put 'ROUND7_PASS=B3035';
else put 'ERROR: ROUND7_FAIL=B3035 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3035:; quit;
