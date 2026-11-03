/* B3039 goto_local_label, N=10; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3039a; do x=1 to 10; if mod(x,2)=0 then goto even; score=x; goto emit;
even: score=10*x;
emit: output; end; stop; run;
proc sql; create table b3039o as select sum(score) as actual from b3039a; quit;

data _null_; if 0 then set b3039o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3039 rows=' rows;
else do; set b3039o; if not missing(actual) and abs(actual-(325))<=1e-9*max(1,abs(325)) then put 'ROUND7_PASS=B3039';
else put 'ERROR: ROUND7_FAIL=B3039 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3039:; quit;
