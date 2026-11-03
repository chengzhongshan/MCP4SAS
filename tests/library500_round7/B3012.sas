/* B3012 select_without_expression, N=3; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3012a; do x=-3 to 3; select; when(x<0) score=-x; when(x=0) score=10; otherwise score=2*x; end; output; end; run;
proc sql; create table b3012o as select sum(score) as actual from b3012a; quit;

data _null_; if 0 then set b3012o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3012 rows=' rows;
else do; set b3012o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND7_PASS=B3012';
else put 'ERROR: ROUND7_FAIL=B3012 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3012:; quit;
