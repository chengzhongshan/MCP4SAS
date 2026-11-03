/* B3020 select_without_expression, N=11; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3020a; do x=-11 to 11; select; when(x<0) score=-x; when(x=0) score=10; otherwise score=2*x; end; output; end; run;
proc sql; create table b3020o as select sum(score) as actual from b3020a; quit;

data _null_; if 0 then set b3020o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3020 rows=' rows;
else do; set b3020o; if not missing(actual) and abs(actual-(208))<=1e-9*max(1,abs(208)) then put 'ROUND7_PASS=B3020';
else put 'ERROR: ROUND7_FAIL=B3020 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3020:; quit;
