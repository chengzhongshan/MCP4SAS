/* B3003 select_when_otherwise, N=4; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3003a; do code=0 to 4; select(code); when(0) score=100; otherwise score=code; end; output; end; run;
proc sql; create table b3003o as select sum(score) as actual from b3003a; quit;

data _null_; if 0 then set b3003o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3003 rows=' rows;
else do; set b3003o; if not missing(actual) and abs(actual-(110))<=1e-9*max(1,abs(110)) then put 'ROUND7_PASS=B3003';
else put 'ERROR: ROUND7_FAIL=B3003 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3003:; quit;
