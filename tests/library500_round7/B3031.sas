/* B3031 goto_local_label, N=2; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3031a; do x=1 to 2; if mod(x,2)=0 then goto even; score=x; goto emit;
even: score=10*x;
emit: output; end; stop; run;
proc sql; create table b3031o as select sum(score) as actual from b3031a; quit;

data _null_; if 0 then set b3031o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3031 rows=' rows;
else do; set b3031o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND7_PASS=B3031';
else put 'ERROR: ROUND7_FAIL=B3031 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3031:; quit;
