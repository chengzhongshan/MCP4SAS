/* B3034 goto_local_label, N=5; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3034a; do x=1 to 5; if mod(x,2)=0 then goto even; score=x; goto emit;
even: score=10*x;
emit: output; end; stop; run;
proc sql; create table b3034o as select sum(score) as actual from b3034a; quit;

data _null_; if 0 then set b3034o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3034 rows=' rows;
else do; set b3034o; if not missing(actual) and abs(actual-(69))<=1e-9*max(1,abs(69)) then put 'ROUND7_PASS=B3034';
else put 'ERROR: ROUND7_FAIL=B3034 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3034:; quit;
