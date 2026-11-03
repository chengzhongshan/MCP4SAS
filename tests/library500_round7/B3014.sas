/* B3014 select_without_expression, N=5; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3014a; do x=-5 to 5; select; when(x<0) score=-x; when(x=0) score=10; otherwise score=2*x; end; output; end; run;
proc sql; create table b3014o as select sum(score) as actual from b3014a; quit;

data _null_; if 0 then set b3014o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3014 rows=' rows;
else do; set b3014o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND7_PASS=B3014';
else put 'ERROR: ROUND7_FAIL=B3014 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3014:; quit;
