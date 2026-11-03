/* B3017 select_without_expression, N=8; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3017a; do x=-8 to 8; select; when(x<0) score=-x; when(x=0) score=10; otherwise score=2*x; end; output; end; run;
proc sql; create table b3017o as select sum(score) as actual from b3017a; quit;

data _null_; if 0 then set b3017o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3017 rows=' rows;
else do; set b3017o; if not missing(actual) and abs(actual-(118))<=1e-9*max(1,abs(118)) then put 'ROUND7_PASS=B3017';
else put 'ERROR: ROUND7_FAIL=B3017 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3017:; quit;
