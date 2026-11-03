/* B3093 multiple_set_shorter_stream, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data b3093a; do x=1 to 4+2; output; end; run;
data b3093b; do y=1 to 4; output; end; run;
data b3093c; set b3093a; set b3093b; value=x+y; run;
proc sql; create table b3093o as select sum(value) as actual from b3093c; quit;

data _null_; if 0 then set b3093o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3093 rows=' rows;
else do; set b3093o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND7_PASS=B3093';
else put 'ERROR: ROUND7_FAIL=B3093 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3093:; quit;
