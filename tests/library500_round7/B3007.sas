/* B3007 select_when_otherwise, N=8; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3007a; do code=0 to 8; select(code); when(0) score=100; otherwise score=code; end; output; end; run;
proc sql; create table b3007o as select sum(score) as actual from b3007a; quit;

data _null_; if 0 then set b3007o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3007 rows=' rows;
else do; set b3007o; if not missing(actual) and abs(actual-(136))<=1e-9*max(1,abs(136)) then put 'ROUND7_PASS=B3007';
else put 'ERROR: ROUND7_FAIL=B3007 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3007:; quit;
