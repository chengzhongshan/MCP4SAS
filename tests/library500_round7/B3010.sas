/* B3010 select_when_otherwise, N=11; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3010a; do code=0 to 11; select(code); when(0) score=100; otherwise score=code; end; output; end; run;
proc sql; create table b3010o as select sum(score) as actual from b3010a; quit;

data _null_; if 0 then set b3010o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3010 rows=' rows;
else do; set b3010o; if not missing(actual) and abs(actual-(166))<=1e-9*max(1,abs(166)) then put 'ROUND7_PASS=B3010';
else put 'ERROR: ROUND7_FAIL=B3010 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3010:; quit;
