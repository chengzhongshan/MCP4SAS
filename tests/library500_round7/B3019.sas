/* B3019 select_without_expression, N=10; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3019a; do x=-10 to 10; select; when(x<0) score=-x; when(x=0) score=10; otherwise score=2*x; end; output; end; run;
proc sql; create table b3019o as select sum(score) as actual from b3019a; quit;

data _null_; if 0 then set b3019o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3019 rows=' rows;
else do; set b3019o; if not missing(actual) and abs(actual-(175))<=1e-9*max(1,abs(175)) then put 'ROUND7_PASS=B3019';
else put 'ERROR: ROUND7_FAIL=B3019 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3019:; quit;
