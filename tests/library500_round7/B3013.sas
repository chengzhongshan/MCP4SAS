/* B3013 select_without_expression, N=4; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3013a; do x=-4 to 4; select; when(x<0) score=-x; when(x=0) score=10; otherwise score=2*x; end; output; end; run;
proc sql; create table b3013o as select sum(score) as actual from b3013a; quit;

data _null_; if 0 then set b3013o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3013 rows=' rows;
else do; set b3013o; if not missing(actual) and abs(actual-(40))<=1e-9*max(1,abs(40)) then put 'ROUND7_PASS=B3013';
else put 'ERROR: ROUND7_FAIL=B3013 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3013:; quit;
