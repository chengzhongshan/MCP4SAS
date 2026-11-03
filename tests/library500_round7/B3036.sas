/* B3036 goto_local_label, N=7; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3036a; do x=1 to 7; if mod(x,2)=0 then goto even; score=x; goto emit;
even: score=10*x;
emit: output; end; stop; run;
proc sql; create table b3036o as select sum(score) as actual from b3036a; quit;

data _null_; if 0 then set b3036o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3036 rows=' rows;
else do; set b3036o; if not missing(actual) and abs(actual-(136))<=1e-9*max(1,abs(136)) then put 'ROUND7_PASS=B3036';
else put 'ERROR: ROUND7_FAIL=B3036 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3036:; quit;
