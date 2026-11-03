/* B3082 delete_and_explicit_outputs, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3082a; do x=1 to 2*3; output; end; run;
data b3082b; set b3082a; if mod(x,2)=1 then delete; output; output; run;
proc sql; create table b3082o as select sum(x) as actual from b3082b; quit;

data _null_; if 0 then set b3082o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3082 rows=' rows;
else do; set b3082o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND7_PASS=B3082';
else put 'ERROR: ROUND7_FAIL=B3082 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3082:; quit;
