/* B3006 select_when_otherwise, N=7; source: Cody's Data Cleaning Techniques Using SAS Software.txt:1383 */

data b3006a; do code=0 to 7; select(code); when(0) score=100; otherwise score=code; end; output; end; run;
proc sql; create table b3006o as select sum(score) as actual from b3006a; quit;

data _null_; if 0 then set b3006o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3006 rows=' rows;
else do; set b3006o; if not missing(actual) and abs(actual-(128))<=1e-9*max(1,abs(128)) then put 'ROUND7_PASS=B3006';
else put 'ERROR: ROUND7_FAIL=B3006 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3006:; quit;
