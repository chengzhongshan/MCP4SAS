/* B3033 goto_local_label, N=4; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3033a; do x=1 to 4; if mod(x,2)=0 then goto even; score=x; goto emit;
even: score=10*x;
emit: output; end; stop; run;
proc sql; create table b3033o as select sum(score) as actual from b3033a; quit;

data _null_; if 0 then set b3033o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3033 rows=' rows;
else do; set b3033o; if not missing(actual) and abs(actual-(64))<=1e-9*max(1,abs(64)) then put 'ROUND7_PASS=B3033';
else put 'ERROR: ROUND7_FAIL=B3033 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3033:; quit;
