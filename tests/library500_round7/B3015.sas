/* B3015 select_without_expression, N=6; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3015a; do x=-6 to 6; select; when(x<0) score=-x; when(x=0) score=10; otherwise score=2*x; end; output; end; run;
proc sql; create table b3015o as select sum(score) as actual from b3015a; quit;

data _null_; if 0 then set b3015o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3015 rows=' rows;
else do; set b3015o; if not missing(actual) and abs(actual-(73))<=1e-9*max(1,abs(73)) then put 'ROUND7_PASS=B3015';
else put 'ERROR: ROUND7_FAIL=B3015 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3015:; quit;
