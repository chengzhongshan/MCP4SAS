/* B3009 select_when_otherwise, N=10; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3009a; do code=0 to 10; select(code); when(0) score=100; otherwise score=code; end; output; end; run;
proc sql; create table b3009o as select sum(score) as actual from b3009a; quit;

data _null_; if 0 then set b3009o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3009 rows=' rows;
else do; set b3009o; if not missing(actual) and abs(actual-(155))<=1e-9*max(1,abs(155)) then put 'ROUND7_PASS=B3009';
else put 'ERROR: ROUND7_FAIL=B3009 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3009:; quit;
