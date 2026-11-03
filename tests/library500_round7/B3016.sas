/* B3016 select_without_expression, N=7; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3016a; do x=-7 to 7; select; when(x<0) score=-x; when(x=0) score=10; otherwise score=2*x; end; output; end; run;
proc sql; create table b3016o as select sum(score) as actual from b3016a; quit;

data _null_; if 0 then set b3016o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3016 rows=' rows;
else do; set b3016o; if not missing(actual) and abs(actual-(94))<=1e-9*max(1,abs(94)) then put 'ROUND7_PASS=B3016';
else put 'ERROR: ROUND7_FAIL=B3016 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3016:; quit;
