/* B3008 select_when_otherwise, N=9; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3008a; do code=0 to 9; select(code); when(0) score=100; otherwise score=code; end; output; end; run;
proc sql; create table b3008o as select sum(score) as actual from b3008a; quit;

data _null_; if 0 then set b3008o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3008 rows=' rows;
else do; set b3008o; if not missing(actual) and abs(actual-(145))<=1e-9*max(1,abs(145)) then put 'ROUND7_PASS=B3008';
else put 'ERROR: ROUND7_FAIL=B3008 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3008:; quit;
