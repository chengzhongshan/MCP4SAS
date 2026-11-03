/* B3037 goto_local_label, N=8; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3037a; do x=1 to 8; if mod(x,2)=0 then goto even; score=x; goto emit;
even: score=10*x;
emit: output; end; stop; run;
proc sql; create table b3037o as select sum(score) as actual from b3037a; quit;

data _null_; if 0 then set b3037o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3037 rows=' rows;
else do; set b3037o; if not missing(actual) and abs(actual-(216))<=1e-9*max(1,abs(216)) then put 'ROUND7_PASS=B3037';
else put 'ERROR: ROUND7_FAIL=B3037 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3037:; quit;
