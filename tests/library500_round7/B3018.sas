/* B3018 select_without_expression, N=9; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3018a; do x=-9 to 9; select; when(x<0) score=-x; when(x=0) score=10; otherwise score=2*x; end; output; end; run;
proc sql; create table b3018o as select sum(score) as actual from b3018a; quit;

data _null_; if 0 then set b3018o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3018 rows=' rows;
else do; set b3018o; if not missing(actual) and abs(actual-(145))<=1e-9*max(1,abs(145)) then put 'ROUND7_PASS=B3018';
else put 'ERROR: ROUND7_FAIL=B3018 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3018:; quit;
