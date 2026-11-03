/* B3002 select_when_otherwise, N=3; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3002a; do code=0 to 3; select(code); when(0) score=100; otherwise score=code; end; output; end; run;
proc sql; create table b3002o as select sum(score) as actual from b3002a; quit;

data _null_; if 0 then set b3002o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3002 rows=' rows;
else do; set b3002o; if not missing(actual) and abs(actual-(106))<=1e-9*max(1,abs(106)) then put 'ROUND7_PASS=B3002';
else put 'ERROR: ROUND7_FAIL=B3002 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3002:; quit;
