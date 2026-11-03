/* B3032 goto_local_label, N=3; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:85 */

data b3032a; do x=1 to 3; if mod(x,2)=0 then goto even; score=x; goto emit;
even: score=10*x;
emit: output; end; stop; run;
proc sql; create table b3032o as select sum(score) as actual from b3032a; quit;

data _null_; if 0 then set b3032o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3032 rows=' rows;
else do; set b3032o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND7_PASS=B3032';
else put 'ERROR: ROUND7_FAIL=B3032 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3032:; quit;
