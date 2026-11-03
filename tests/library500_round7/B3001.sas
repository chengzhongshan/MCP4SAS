/* B3001 select_when_otherwise, N=2; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3001a; do code=0 to 2; select(code); when(0) score=100; otherwise score=code; end; output; end; run;
proc sql; create table b3001o as select sum(score) as actual from b3001a; quit;

data _null_; if 0 then set b3001o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3001 rows=' rows;
else do; set b3001o; if not missing(actual) and abs(actual-(103))<=1e-9*max(1,abs(103)) then put 'ROUND7_PASS=B3001';
else put 'ERROR: ROUND7_FAIL=B3001 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3001:; quit;
