/* B3004 select_when_otherwise, N=5; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3004a; do code=0 to 5; select(code); when(0) score=100; otherwise score=code; end; output; end; run;
proc sql; create table b3004o as select sum(score) as actual from b3004a; quit;

data _null_; if 0 then set b3004o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3004 rows=' rows;
else do; set b3004o; if not missing(actual) and abs(actual-(115))<=1e-9*max(1,abs(115)) then put 'ROUND7_PASS=B3004';
else put 'ERROR: ROUND7_FAIL=B3004 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3004:; quit;
