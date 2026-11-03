/* B3011 select_without_expression, N=2; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3011a; do x=-2 to 2; select; when(x<0) score=-x; when(x=0) score=10; otherwise score=2*x; end; output; end; run;
proc sql; create table b3011o as select sum(score) as actual from b3011a; quit;

data _null_; if 0 then set b3011o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3011 rows=' rows;
else do; set b3011o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND7_PASS=B3011';
else put 'ERROR: ROUND7_FAIL=B3011 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3011:; quit;
