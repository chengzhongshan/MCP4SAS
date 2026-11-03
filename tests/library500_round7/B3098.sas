/* B3098 multiple_set_shorter_stream, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data b3098a; do x=1 to 9+2; output; end; run;
data b3098b; do y=1 to 9; output; end; run;
data b3098c; set b3098a; set b3098b; value=x+y; run;
proc sql; create table b3098o as select sum(value) as actual from b3098c; quit;

data _null_; if 0 then set b3098o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3098 rows=' rows;
else do; set b3098o; if not missing(actual) and abs(actual-(90))<=1e-9*max(1,abs(90)) then put 'ROUND7_PASS=B3098';
else put 'ERROR: ROUND7_FAIL=B3098 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3098:; quit;
