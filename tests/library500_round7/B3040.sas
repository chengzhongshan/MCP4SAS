/* B3040 goto_local_label, N=11; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3040a; do x=1 to 11; if mod(x,2)=0 then goto even; score=x; goto emit;
even: score=10*x;
emit: output; end; stop; run;
proc sql; create table b3040o as select sum(score) as actual from b3040a; quit;

data _null_; if 0 then set b3040o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3040 rows=' rows;
else do; set b3040o; if not missing(actual) and abs(actual-(336))<=1e-9*max(1,abs(336)) then put 'ROUND7_PASS=B3040';
else put 'ERROR: ROUND7_FAIL=B3040 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3040:; quit;
