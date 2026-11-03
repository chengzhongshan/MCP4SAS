/* B3005 select_when_otherwise, N=6; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3005a; do code=0 to 6; select(code); when(0) score=100; otherwise score=code; end; output; end; run;
proc sql; create table b3005o as select sum(score) as actual from b3005a; quit;

data _null_; if 0 then set b3005o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3005 rows=' rows;
else do; set b3005o; if not missing(actual) and abs(actual-(121))<=1e-9*max(1,abs(121)) then put 'ROUND7_PASS=B3005';
else put 'ERROR: ROUND7_FAIL=B3005 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3005:; quit;
